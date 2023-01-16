module hoteldb

import freeflowuniverse.backoffice.finance
import freeflowuniverse.crystallib.timetools {time_from_string}

import time
import os
import json

pub struct Purchase {
	date 	       string
	product_id     string
	product_name   string
	customer_id    string
	customer_name  string
	quantity       int // units/nights/hours
	total_price    finance.Amount
	// TODO should add unique purchase id
}

pub struct PurchaseArgs {
	date        string
	product_id  string [required]
	customer_id string [required]
	quantity    string = '2'
	// duplicate   bool // set true if you want to log an identical purchase multiple times
}

pub fn (db HotelDB) log_purchase (o PurchaseArgs) ! {
	mut date := time.Time{}
	if o.date == '' {
		date = time.now()
	} else {
		date = time_from_string(o.date) or {return error('Failed to get time from date string: $o.date')}
	}
	
	product := db.get_product(o.product_id) or {return error('Failed to get product $o.product_id: $err')}
	customer := db.get_customer_by_id(o.customer_id) or {return error('Failed to get customer $o.customer_id: $err')}

	c_name := customer.name()

	mut total_price := finance.Amount{
		val: product.price.val*o.quantity.int()
	}

	purchase := Purchase{
		date: date.str()
		product_id: o.product_id
		product_name: product.name
		customer_id: o.customer_id
		customer_name: c_name
		quantity: o.quantity.int()
		total_price: total_price
	}


	json_purchase := json.encode(purchase)
	// if o.duplicate == false {
	// 	println(db.log_file.path)
	// 	mut json_purchases := os.read_lines(db.log_file.path) or {return error("Failed to read log file: $err")}
	// 	if json_purchase in json_purchases {
	// 		return error("Purchase already logged. Add 'duplicate: true' if this duplication was intended")
	// 	}
	// }

	mut log_file := os.open_append(db.log_file.path) or {return error("Failed to open log file: $err")}
	log_file.writeln(json_purchase) or {return error("Failed to write purchase: $purchase to purchase log: $err")}
	log_file.close()
}

