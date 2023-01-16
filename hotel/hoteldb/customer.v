module hoteldb

pub struct Customer {
	id         string
	firstname  string
	lastname   string
}

// TODO placeholder, ideally we do firstname lastname as inputs
pub fn (hdb HotelDB) get_customer (id string) &Customer {
	for customer in hdb.customers {
		if customer.id == id {
			return &customer
		}
	}
}