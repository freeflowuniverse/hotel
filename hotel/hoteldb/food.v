module hoteldb

import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.texttools

pub enum FoodType {
	starter
	main 
	dessert
}

[heap] 
pub struct Food{
	ProductMixin
	ConsumableMixin
pub mut:
	breakfast bool
	halal     bool
	food_type FoodType
}

pub fn (db HotelDB) get_foods () []Food{
	return db.get_products('food').map(it as Food)
}

// ! Can be replaced by db.products.filter(it.id==id)
pub fn (db HotelDB) get_food (id string) !Food {
	food := db.get_product(id) or {return error("Failed to get food $id: $err")}
	return food as Food
}

// ! Can be replaced by db.products.filter(it.id!=id)
pub fn (mut db HotelDB) delete_food (id string) ! {
	db.delete_product(id) or {return error("Failed to delete food $id: $err")}
}


// pub fn (db HotelDB) list_food () string {
// 	mut text := '**Food Choices**
// \n'
// 	for product in db.products {
// 		match product {
// 			Food {text += product.stringify()}
// 			else {}
// 		}
// 	}

// 	return text
// }

fn (food Food) stringify () string {
	mut text := ''
	text += food.ProductMixin.stringify()
	text += food.ConsumableMixin.stringify()
	if food.breakfast == true {
		text += 'Breakfast, '
	}
	if food.halal == true {
		text += 'Halal, '
	}
	food_type := '$food.food_type'
	text += '${food_type.capitalize()}, 
	\n'

	return text
}



pub fn (mut db HotelDB) add_food (mut o params.Params) !Product {

	// TODO change the input to a product mixin + function
	food := Food{ // ? Should this be mutable?
		ProductMixin: db.params_to_product(mut o)!
		ConsumableMixin: db.params_to_consumable(mut o)!
		breakfast : o.get('breakfast')!.bool()
		halal : o.get('halal')!.bool()
		food_type : match_food_type(o.get('food_type')!)
	}

	return food
}

fn match_food_type(food_type_ string) FoodType {
	corrected_food_type := texttools.name_fix_no_underscore_no_ext(food_type_)

	food_type := match corrected_food_type {
		'starter' {FoodType.starter}
		'main' {FoodType.main}
		'dessert' {FoodType.dessert}
		else {panic("Food type was inputted incorrectly")} // TODO Need better error reporting
	}

	return food_type
} 