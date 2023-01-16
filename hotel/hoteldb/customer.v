module hoteldb

import freeflowuniverse.crystallib.params

[heap]
pub struct Customer {
pub mut:
	id         		  string
	firstname  		  string
	lastname   		  string
	username          string
}

pub fn (mut db HotelDB) add_customer (mut o params.Params) ! {

	customer := Customer{
		id : o.get('id')!
		firstname : o.get('firstname')!
		lastname : o.get('lastname')!
		username: o.get('username')!
	}

	db.customers << customer
}

// TODO placeholder, ideally we do firstname lastname as inputs
pub fn (db HotelDB) get_customer_by_id (id string) !&Customer {
	for customer in db.customers {
		if customer.id == id {
			return &customer
		}
	}
	return error("Could not find customer $id in hotel database.")
}

pub fn (db HotelDB) get_customer_by_username (username string) !&Customer {
	for customer in db.customers {
		if customer.username == username {
			return &customer
		}
	}
	return error("Could not find customer $username in hotel database.")
}

pub fn (customer Customer) name() string {
	return "$customer.firstname $customer.lastname"
}