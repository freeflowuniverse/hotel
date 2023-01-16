module hoteldb

import freeflowuniverse.crystallib.timetools {time_from_string}
import time
import os
import json

pub struct Purchase {
	date 	  time.Time
	product   &Product
	customer  &Customer
	quantity  int // units/nights/hours
}

pub struct PurchaseArgs {
	date        string
	product_id  string
	customer_id string
	quantity    int
	duplicate   bool // set true if you want to log an identical purchase multiple times
}

pub fn (hdb HotelDB) log_purchase (o PurchaseArgs) {
	mut date := time.Time{}
	if o.date = '' {
		date = time.now()
	} else {
		date = time_from_string(o.date) or {return error('Failed to get time from date string: $o.date')}
	}
	
	product := hdb.get_product(o.product_id)
	customer := hdb.get_customer(o.customer_id)

	purchase := Purchase{
		date: date
		product: product
		customer: customer
		quantity: o.quantity
	}

	json_purchase := json.encode(purchase)
	if duplicate == false {
		mut json_purchases := os.read_lines(hdb.log_file.path) or {return error("Failed to read log file: $err")}
		if json_purchase in json_purchases {
			return error("Purchase already logged, add 'duplicate: true' if this was intended")
		}
		continue
	}

	mut log_file := os.open_append(hdb.log_file.path) or {return error("Failed to open log file: $err")}
	log_file.writeln(json_purchase) or {return error("Failed to write purchase: $purchase to purchase log: $err")}
	log_file.close()
}

