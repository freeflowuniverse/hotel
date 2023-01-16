module hoteldb

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.params

pub struct Allergen {
	name    	 string
}

pub struct ConsumableMixin{
pub mut:
	calories        int
	vegetarian      bool
	vegan           bool
	allergens       []&Allergen
}


// input is a string list
pub fn (hdb HotelDB) get_allergens (names_string string) []&Allergen {

	allergen_names := texttools.name_fix_no_underscore_no_ext(names_string).split(',')

	mut allergens := []&Allergen{} // ? is this the correct way to define this?

	for allergen in hdb.allergens {
		if allergen.name in allergen_names {
			allergens << allergen
		}
	}

	return allergens 
}

pub fn (hdb HotelDB) add_allergen (o params.Params) {
	allergen := Allergen {
		name: os.get('name')
	}

	hdb.allergens << allergen 
}








