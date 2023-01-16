module hoteldb

import freeflowuniverse.backoffice.finance
import freeflowuniverse.crystallib.texttools

type Product = Beverage | Food | Room | Boat

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


pub fn (hdb HotelDB) get_product (id string) &Product {
	for product in hdb.products {
		if product.id == id {
			return &product
		}
	}
}

pub fn match_state(state_ string) ProductState {
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