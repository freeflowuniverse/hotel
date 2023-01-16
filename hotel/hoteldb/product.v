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
		id : o.get('id')!
		name : o.get('name')!
		url : o.get('url')!
		description : o.get('description')!
		price : finance.amount_get(o.get('price')!)
		state: match_state(o.get('state')!)
	}
}

fn (mut db HotelDB) add_product (mut action actionparser.Action) ! {

	match action.name.split('.')[1] {
		'food' {db.add_food(mut action.params) or {return error("Failed to add food: \n${err}")}}
		'beverage' {db.add_beverage(mut action.params) or {return error("Failed to add beverage: \n${err}")}}
		'room' {db.add_room(mut action.params) or {return error("Failed to add room: \n${err}")}}
		'boat' {db.add_boat(mut action.params) or {return error("Failed to add boat: \n${err}")}}
		else {return error("Incorrect command: ${action.name.split('.')[1]}, please ensure product is followed by 'food', 'beverage', 'room' or 'boat'")}
	}
}

pub fn (db HotelDB) get_product (id string) !Product {
	for product in db.products {
		if product.id == id {
			return product // TODO this should be a reference but this creates issues
		}
	}
	return error("Could not find product $id in hotel database.")
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