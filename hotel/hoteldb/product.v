module hoteldb

import freeflowuniverse.backoffice.finance
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.params

[heap]
pub type Product = Beverage | Food | Room | Boat

pub enum ProductState{
	ok
	planned
	unavailable
	endoflife
	error
}

pub struct ProductMixin{
pub mut:
	id          string
	name        string
	url         string
	description string
	price       finance.Amount
	state       ProductState	
}

pub fn (db HotelDB) check_product_exists (id string) bool {
	for product in db.products {
		if product.id == id {
			return true
		}
	}
	return false
}

pub fn (db HotelDB) get_product_stringified (product_id string) !string {

	product := db.get_product(product_id) or {return error("Failed to get product: $err")}

	mut text := ''

	match product {
		Food {text = product.stringify()}
		Beverage {text = product.stringify()}
		Room {text = product.stringify()}
		Boat {text = product.stringify()}
	}

	return text
}

pub fn (db HotelDB) get_products_stringified (product_type string) string {
	mut text := '**${product_type.capitalize()} Choices**
\n'
	full_type := 'freeflowuniverse.hotel.hotel.hoteldb.${product_type}'
	for product in db.products {
		// println(product.type_name())
		if product.type_name() == full_type {
			match product {
				Food {text += product.stringify()}
				Beverage {text += product.stringify()}
				Room {text += product.stringify()}
				Boat {text += product.stringify()}
			}
		}
	}

	return text
}

pub fn (db HotelDB) get_products (product_type string) []Product {
	full_type := 'freeflowuniverse.hotel.hotel.hoteldb.${product_type}'
	mut products := []Product{}
	for product in db.products {
		if product.type_name() == full_type {
			products << product // TODO this should be a reference but this creates issues
		}
	}
	return products
}

pub fn (db HotelDB) get_product (id string) !Product {
	for product in db.products {
		if product.id == id {
			return product // TODO this should be a reference but this creates issues
		}
	}
	return error("Could not find product $id in hotel database.")
}

pub fn (mut db HotelDB) delete_product(id string) ! {
	mut found := false
	for product in db.products {
		if product.id == id {
			db.products = db.products.filter(it.id!=id) // TODO check that this is valid
		}
	}
	if found == false {
		return error("Could not find product $id in hotel database.")
	}
}

fn (pm ProductMixin) stringify () string {

	price := pm.price.usd().str().trim_string_right('.0')

	text := '_${pm.name}_
Order ID: $pm.id
Description: $pm.description
Price: ${price}USD
'
	return text
}

fn (mut db HotelDB) params_to_product (mut o params.Params) !ProductMixin {
	return ProductMixin{
		id : db.generate_product_id()
		name : o.get('name')!
		url : o.get('url')!
		description : o.get('description')!
		price : db.currencies.amount_get(o.get('price')!)!
		state: match_state(o.get('state')!)
	}
}

fn (mut db HotelDB) add_product (mut action actionparser.Action) ! {

	new_product := match action.name.split('.')[1] {
		'food' {db.add_food(mut action.params) or {return error("Failed to add food: \n${err}")}}
		'beverage' {db.add_beverage(mut action.params) or {return error("Failed to add beverage: \n${err}")}}
		'room' {db.add_room(mut action.params) or {return error("Failed to add room: \n${err}")}}
		'boat' {db.add_boat(mut action.params) or {return error("Failed to add boat: \n${err}")}}
		else {Food{name: 'ERROR'}} // TODO this needs to be fixed!!
	}

	if new_product.name == 'ERROR' {
		return error("Incorrect command: ${action.name.split('.')[1]}, please ensure product is followed by 'food', 'beverage', 'room' or 'boat'")
	}

	for product in db.products {
		if new_product.name == product.name && new_product.url == product.url && new_product.description == product.description {
			return error("This product already exists in the database")
		} else {
			db.products << new_product
		}
	}
}

fn match_state(state_ string) ProductState {
	corrected_state := texttools.name_fix_no_underscore_no_ext(state_)

	state := match corrected_state {
		'ok' {ProductState.ok}
		'planned' {ProductState.planned}
		'unavailable' {ProductState.unavailable}
		'endoflife' {ProductState.endoflife}
		'error' {ProductState.error}
		else {panic("State was inputted incorrectly")} // TODO Need better error reporting
	}

	return state
}

fn (db HotelDB) generate_product_id () string {
	mut greatest_id := 0
	for product in db.products {
		if product.id.int() > greatest_id {
			greatest_id = product.id.int()
		}
	}
	return (greatest_id + 1).str()
}