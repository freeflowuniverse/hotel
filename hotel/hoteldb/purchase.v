module hoteldb

import freeflowuniverse.backoffice.finance
import freeflowuniverse.crystallib.timetools {time_from_string}

import time
import os
import json

pub struct Purchase {
	id           string
	date         time.Time
	product      &Product
	customer     &Customer
	quantity     int // units/nights/hours
	total_price  finance.Amount
	// TODO should add unique purchase id
}

pub struct PurchaseArgs {
	date        string
	product_id  string [required]
	customer_id string [required]
	quantity    string = '2'
	// duplicate   bool // set true if you want to log an identical purchase multiple times
}

pub fn (db HotelDB) get_purchases () []Purchase {
	mut purchases := []Purchase{}
	for purchase in db.purchases {
		purchases << purchase
	}
	return purchases
}

pub fn (db HotelDB) get_purchase (id string) !Purchase {
	for purchase in db.purchases {
		if purchase.id == id {
			return purchase
		}
	}
	return error("Could not find purchase $id in hotel database.")
}

pub fn (mut db HotelDB) delete_purchase (id string) ! {
	mut found := false
	for purchase in db.purchases {
		if purchase.id == id {
			db.purchases = db.purchases.filter(it.id!=id) // TODO check that this is valid
		}
	}
	if found == false {
		return error("Could not find purchase $id in hotel database.")
	}
}

pub fn (mut db HotelDB) add_purchase (o PurchaseArgs) ! {
	mut date := time.Time{}
	if o.date == '' {
		date = time.now()
	} else {
		date = time_from_string(o.date) or {return error('Failed to get time from date string: $o.date')}
	}
	
	id := db.generate_purchase_id()

	product := db.get_product(o.product_id) or {return error('Failed to get product $o.product_id: $err')}
	customer := db.get_customer(o.customer_id) or {return error('Failed to get customer $o.customer_id: $err')}

	c_name := customer.name()

	total_price := db.currencies.amount_get((product.price.val*o.quantity.int()).str()) or {return error("Failed to get amount: $err")}

	purchase := Purchase{
		id: id
		date: date
		product: &product
		customer: customer
		quantity: o.quantity.int()
		total_price: total_price
	}

	db.purchases << purchase

	// json_purchase := json.encode(purchase)
	// if o.duplicate == false {
	// 	println(db.log_file.path)
	// 	mut json_purchases := os.read_lines(db.log_file.path) or {return error("Failed to read log file: $err")}
	// 	if json_purchase in json_purchases {
	// 		return error("Purchase already logged. Add 'duplicate: true' if this duplication was intended")
	// 	}
	// }

	// mut log_file := os.open_append(db.log_file.path) or {return error("Failed to open log file: $err")}
	// log_file.writeln(json_purchase) or {return error("Failed to write purchase: $purchase to purchase log: $err")}
	// log_file.close()
}

pub fn (db HotelDB) generate_purchase_id () string {
	mut greatest_id := 0
	for purchase in db.purchases {
		if purchase.id.int() > greatest_id {
			greatest_id = purchase.id.int()
		}
	}
	return (greatest_id + 1).str()
}