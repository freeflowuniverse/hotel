module hoteldb

import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.texttools

pub enum BoatType {
	sail
	motorized
}

// TODO polish this up
pub enum ExperienceRequired {
	nothing
	drivers_license
	sailing_license
}

[heap]
pub struct Boat{
	ProductMixin
pub mut:
	boat_type            BoatType
	horsepower           int
	experience_required  ExperienceRequired
}


pub fn (db HotelDB) get_boats () []Boat{
	boats := db.get_products('boat').map(it as Boat)
	return boats
}

pub fn (db HotelDB) get_boat (id string) !Boat {
	boat := db.get_product(id) or {return error("Failed to get boat $id: $err")}
	return boat as Boat
}

pub fn (mut db HotelDB) delete_boat (id string) ! {
	db.delete_product(id) or {return error("Failed to delete boat $id: $err")}
}

pub fn (mut db HotelDB) add_boat (mut o params.Params) !Product {

	boat := Boat{
		ProductMixin: db.params_to_product(mut o)!
		boat_type : match_boat_type(o.get('boat_type')!)
		horsepower : o.get('horsepower')!.int()
		experience_required : match_experience_required(o.get('experience_required')!)
	}

	return boat
}

fn (boat Boat) stringify () string {
	mut text := boat.ProductMixin.stringify()

	boat_type := '$boat.boat_type'
	experience_required := '$boat.experience_required'

	text += 'Boat Type: ${boat_type.capitalize()}
Horsepower: ${boat.horsepower}
Experience Required: ${experience_required.capitalize()}\n'

	return text
}


pub fn match_boat_type(boat_type_ string) BoatType {
	corrected_boat_type := texttools.name_fix_no_underscore_no_ext(boat_type_)

	boat_type := match corrected_boat_type {
		'sail' {BoatType.sail}
		'motorized' {BoatType.motorized}
		else {panic("Boat type was inputted incorrectly")} // TODO Need better error reporting
	}

	return boat_type
} 

pub fn match_experience_required(experience_required_ string) ExperienceRequired {
	corrected_experience_required := texttools.name_fix_no_underscore_no_ext(experience_required_)

	experience_required := match corrected_experience_required {
		'nothing' {ExperienceRequired.nothing}
		'drivers_license' {ExperienceRequired.drivers_license}
		'sailing_license' {ExperienceRequired.sailing_license}
		else {panic("Experience required was inputted incorrectly")} // TODO Need better error reporting
	}

	return experience_required
} 