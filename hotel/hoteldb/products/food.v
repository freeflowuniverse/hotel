module hoteldb

import freeflowuniverse.crystalib.params
import freeflowuniverse.crystallib.texttools

pub enum FoodType {
	starter
	main 
	dessert
}

[heap] 
pub struct Food{
	BaseMixin
	ConsumableMixin
pub mut:
	breakfast bool
	halal     bool
	food_type FoodType
}

pub fn (hdb HotelDB) add_food (o params.Params) {

	food := Food{ // ? Should this be mutable?
		id : o.get('id')
		name : o.get('name')
		url : o.get('url')
		description : o.get('description')
		price : amount_get(o.get('price'))
		state: match_state(o.get('state'))
		calories : o.get('calories').int()
		vegetarian : o.get('vegetarian').bool()
		vegan : o.get('vegan').bool()
		allergens: hdb.get_allergens(os.get('allergens'))
		breakfast : o.get('breakfast').bool()
		halal : o.get('halal').bool()
		food_type : match_food_type(o.get('food_type'))
	}

	hdb.products << food
}

pub fn match_food_type(food_type_ string) FoodType {
	corrected_food_type := texttools.name_fix_no_underscore_no_ext(food_type_)

	food_type := match corrected_food_type {
		'starter' {FoodType.starter}
		'main' {FoodType.main}
		'dessert' {FoodType.dessert}
		else {panic("Food type was inputted incorrectly")} // TODO Need better error reporting
	}

	return food_type
} 