module hoteldb

import freeflowuniverse.backoffice.finance
import freeflowuniverse.crystallib.timetools

import time

pub struct Purchase {
	id           string
	date         time.Time
	product      &Product
	customer     &Customer
	quantity     int // units/nights/hours
	total_amount  finance.Amount
	// TODO should add unique purchase id
}

// struct Customer {
// 	purchases []Purchase
// }

pub struct PurchaseArgs {
	date        string
	product_id  string [required]
	customer_id string [required]
	quantity    string
	hard        string
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

pub fn (db HotelDB) get_purchase_stringified(id string) !string {
	purchase := db.get_purchase(id) or {return error("Failed to find purchase $id: $err")}
	text := '
Purchase ID: $purchase.id
Customer: $purchase.customer.id - $purchase.customer.firstname $purchase.customer.lastname
Product: $purchase.product.id - $purchase.product.name
Date: $purchase.date
Quantity: $purchase.quantity
Total Amount: ${purchase.total_amount.val}${purchase.total_amount.currency.name}/n'
	return text
}

pub fn (db HotelDB) get_purchases_stringified() string {
	mut text := 'Hotel Purchases:/n'
	for purchase in db.purchases {
		text += db.get_purchase_stringified(purchase.id) or {''}
	}
	return text
}

// ? maybe this shouldn't exist?
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
		date = timetools.time_from_string(o.date) or {return error('Failed to get time from date string: $o.date')}
	}
	
	id := db.generate_purchase_id()

	product := db.get_product(o.product_id) or {return error('Failed to get product $o.product_id: $err')}
	customer := db.get_customer(o.customer_id) or {return error('Failed to get customer $o.customer_id: $err')}

	mut total_amount := db.currencies.amount_get((product.price.val*o.quantity.int()).str()) or {return error("Failed to get amount: $err")}

	purchase := Purchase{
		id: id
		date: date
		product: &product
		customer: customer
		quantity: o.quantity.int()
		total_amount: total_amount
	}

	mut hard_transfer := false
	if o.hard == 'true' {
		hard_transfer = true
	}

	db.transfer_fund_to_hotel(o.customer_id, mut total_amount, hard_transfer) or {return error("Failed to transfer ${total_amount.val}${total_amount.currency.name} to hotel")}

	db.purchases << purchase
}

fn (db HotelDB) generate_purchase_id () string {
	mut greatest_id := 0
	for purchase in db.purchases {
		if purchase.id.int() > greatest_id {
			greatest_id = purchase.id.int()
		}
	}
	return (greatest_id + 1).str()
}