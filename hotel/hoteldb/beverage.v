module hoteldb

import freeflowuniverse.crystallib.params

[heap] 
pub struct Beverage{
	ProductMixin
	ConsumableMixin
pub mut:
	alcoholic   bool
}

pub fn (mut db HotelDB) add_beverage (mut o params.Params) !Product {

	beverage := Beverage{
		ProductMixin: db.params_to_product(mut o)!
		ConsumableMixin: db.params_to_consumable(mut o)!
		alcoholic: o.get('alcoholic')!.bool()
	}

	return beverage
}

pub fn (db HotelDB) get_beverages () []Beverage{
	return db.get_products('beverage').map(it as Beverage)
}

// ! Can be replaced by db.products.filter(it.id==id)
pub fn (db HotelDB) get_beverage (id string) !Beverage {
	beverage := db.get_product(id) or {return error("Failed to get beverage $id: $err")}
	return beverage as Beverage
}

// ! Can be replaced by db.products.filter(it.id!=id)
pub fn (mut db HotelDB) delete_beverage (id string) ! {
	db.delete_product(id) or {return error("Failed to delete beverage $id: $err")}
}

// ! get_products('beverage')
// pub fn (db HotelDB) list_beverages () string {
// 	mut text := '**Beverage Choices**
// \n'
// 	for product in db.products {
// 		match product {
// 			Beverage {text += product.stringify()}
// 			else {}
// 		}
// 	}

// 	return text
// }

fn (beverage Beverage) stringify () string {
	mut text := ''
	text += beverage.ProductMixin.stringify()
	text += beverage.ConsumableMixin.stringify()
	if beverage.alcoholic == true {
		text += ' Alcoholic, '
	}
	return text
}

