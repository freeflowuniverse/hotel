module product
import freeflowuniverse.hotel.library.finance

pub enum Unit {
	ml
	grams
	units
	cups
	tsp
	tbsp
	person
}

pub enum ProductState{
	ok
	planned
	unavailable
	endoflife
	error
}

pub struct ProductTag {
	name string
}

// goods/services defined with a price, details and standard unit
pub struct Product {
    id string // two digit number
    name string
	description string
    state ProductState
    price finance.Price
    unit Unit
	tags []ProductTag
	constituent_products []ProductAmount
	variable_price bool
}

pub struct ProductAmount {
	product Product // actor_character product_id concatenated
	quantity string
	total_price finance.Price
}

pub struct ProductActorMixin {}


