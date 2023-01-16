module hoteldb

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.params

[heap]
pub struct Allergen {
	name    	 string
}

pub struct ConsumableMixin{
pub mut:
	calories        int
	vegetarian      bool
	vegan           bool
	allergens       []Allergen //! []&Allergen
}

fn (cm ConsumableMixin) stringify () string {

	mut allergens_str := ''
	for allergen in cm.allergens {
		allergens_str += '$allergen.name, '
	}

	if allergens_str.len == 0 {
		allergens_str += 'None'
	}

	allergens_str.trim_string_right(', ')

	mut text := 'Calories: $cm.calories
Allergens: $allergens_str
Attributes: '

	if cm.vegetarian == true {
		text += 'Vegetarian, '
	}
	if cm.vegan == true {
		text += 'Vegan, '
	}

	return text
}

fn (db HotelDB) params_to_consumable (mut o params.Params) !ConsumableMixin {

	mut allergens := []Allergen{}
	if o.exists('allergens') {
		allergens = db.get_allergens(o.get('allergens')!)!
	}

	return ConsumableMixin{
		calories : o.get('calories')!.int()
		vegetarian : o.get('vegetarian')!.bool()
		vegan : o.get('vegan')!.bool()
		allergens: allergens
	}
}

// input is a string list
fn (db HotelDB) get_allergens (names_string string) ![]Allergen { //! []&Allergen {

	allergen_names := texttools.name_fix_no_underscore_no_ext(names_string).split(',')

	mut allergens := []Allergen{} //! []&Allergen{}

	mut db_names := []string{}
	for allergen in db.allergens {
		db_names << allergen.name
	}

	for allergen in allergen_names{
		if allergen in db_names {
			for db_allergen in db.allergens {
				if db_allergen.name == allergen {
					allergens << db_allergen //! &allergen
				}
			}
		} else {
			return error("Allergen '${allergen}' not recognised.")
		}
	}

	return allergens 
}

fn (mut db HotelDB) add_allergen (mut o params.Params) ! {
	allergen := Allergen {
		name: o.get('name')!
	}

	db.allergens << allergen 
}








