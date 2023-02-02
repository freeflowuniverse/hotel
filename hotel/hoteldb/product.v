module hoteldb

import freeflowuniverse.hotel.finance
import freeflowuniverse.crystallib.params

pub enum ProductState{
	ok
	planned
	unavailable
	endoflife
	error
}

pub struct Product{
pub mut:
	code        string
	name        string
	price       finance.Amount	
	unit        string
	variable    bool // todo add variable price
}

// used by order.v to check if a product code is valid
pub fn (db HotelDB) product_exists (code string) bool {
	for product in db.products {
		if product.code == code {
			return true
		}
	}
	return false
}

// used by order.v to return product when creating an order
pub fn (db HotelDB) get_product (code string) !Product {
	for product in db.products {
		if product.code == code {
			return product
		}
	}
	return error("Product code could not be found")
}

// used to add products to db from actionparser / md files
fn (mut db HotelDB) params_to_product (mut o params.Params) ! {
	product := Product{
		code: o.get('code')!
		name: o.get('name')!
		price: db.currencies.amount_get(o.get('price')!)  or {return error("Failed to get amount: $err")}
		unit: o.get('unit')!
	}

	db.products << product
}
