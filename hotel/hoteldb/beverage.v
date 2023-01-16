module hoteldb

import freeflowuniverse.crystallib.params
import freeflowuniverse.backoffice.finance

[heap] 
pub struct Beverage{
	ProductMixin
	ConsumableMixin
pub mut:
	alcoholic   bool
}

pub fn (db HotelDB) list_beverages () string {
	mut text := '**Beverage Choices**
\n'
	for product in db.products {
		match product {
			Beverage {text += product.stringify()}
			else {}
		}
	}

	return text
}

fn (beverage Beverage) stringify () string {
	mut text := ''
	text += beverage.ProductMixin.stringify()
	text += beverage.ConsumableMixin.stringify()
	if beverage.alcoholic == true {
		text += ' Alcoholic, '
	}
	return text
}

fn (mut db HotelDB) add_beverage (mut o params.Params) ! {

	beverage := Beverage{
		ProductMixin: db.params_to_product(mut o)!
		ConsumableMixin: db.params_to_consumable(mut o)!
		alcoholic: o.get('alcoholic')!.bool()
	}

	db.products << beverage
}