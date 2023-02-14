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
pub mut:
	name string
}

// goods/services defined with a price, details and standard unit
pub struct Product {
pub mut:
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
pub mut:
	product Product // actor_character product_id concatenated
	quantity string
	total_price finance.Price
}

pub fn (p Product) stringify () string {
	mut product_str := 'ID: $p.id\nName: $p.name\nDescription: $p.description\nState: $p.state\nPrice: ${p.price.val}${p.price.currency.name}\nUnit: $p.unit\n'
	if p.tags.len > 0 {
		product_str += 'Tags:\n'
		for tag in p.tags{
			product_str += ' - $tag\n'
		}
	}
	if p.constituent_products.len > 0 {
		product_str += 'Constituent Products:\n'
		for pa in p.constituent_products{
			product_str += ' - $pa.product.name x ${pa.quantity} ${pa.product.unit}\n'
		}
	}
	if p.variable_price {
		product_str += 'This product is of variable price.'
	}
}

pub fn (p Product) short_str () string {
	mut product_str := 'ID: $p.id\nName: $p.name\nPrice: ${p.price.val}${p.price.currency.name}\n'
}

// pub struct ProductActorMixin {}

fn match_code_to_vendor (product_code string) !string {
	return match product_code[0].ascii_str() {
		'K' {'kitchen'}
		'B' {'bar'}
		else {return error("Could not find the key")}
	}
}
