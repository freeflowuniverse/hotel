module product

// todo decide how units should be organised
pub enum Unit {
	ml
	grams
	units
	cups
	tsp
	tbsp
	person
	other
}

pub fn (unit Unit) all () []Unit {
	return [.ml, .grams, .units, .cups, .tsp, .tbsp, .person, .other]
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
    price f64 // usd
    unit Unit
	tags []ProductTag
	constituent_products []ProductAmountRef
	variable_price bool
	actor_name string
}


// ? Issue 1.1 - Should constituent products be references or full product amounts

 
// pub fn (product Product) get_constituents_from (products []Product) ![]ProductAmount {
// 	mut constituents := []ProductAmount{}
// 	for ref in product.constituent_products {
// 		targets := products.filter(it.id == ref.product_id)
// 		if targets.len == 0 {
// 			return error("The product contains constituent products that are not present in the given list of products!")
// 		} 
// 		constituents << targets[0]
// 	}
// 	return constituents
// }


pub struct ProductAmountRef {
pub mut:
	product_id string
	quantity string
}

// pub struct ProductAmount {
// pub mut:
// 	product Product // actor_character product_id concatenated
// 	quantity string
// 	total_price f64 //usd
// }

// pub fn (p Product) stringify () string {
// 	mut product_str := 'ID: $p.id\nName: $p.name\nDescription: $p.description\nState: $p.state\nPrice: ${p.price.amount}${p.price.currency_code}\nUnit: $p.unit\n'
// 	if p.tags.len > 0 {
// 		product_str += 'Tags:\n'
// 		for tag in p.tags{
// 			product_str += ' - $tag\n'
// 		}
// 	}
// 	if p.constituent_products.len > 0 {
// 		product_str += 'Constituent Products:\n'
// 		for pa in p.constituent_products{
// 			product_str += ' - $pa.product.name x ${pa.quantity} ${pa.product.unit}\n'
// 		}
// 	}
// 	if p.variable_price {
// 		product_str += 'This product is of variable price.'
// 	}
// 	return product_str
// }

// pub fn (p Product) short_str () string {
// 	mut product_str := 'ID: $p.id\nName: $p.name\nPrice: ${p.price.val}${p.price.currency.name}\n'
// 	return product_str
// }

// pub struct ProductActorMixin {}

pub fn match_code_to_vendor (product_code string) !string {
	actor_name := match product_code[0].ascii_str() {
		'K' {'kitchen'}
		'B' {'bar'}
		else {''}
	}
	if actor_name == '' {
		return error("Could not find the key")
	}
	return actor_name
}
