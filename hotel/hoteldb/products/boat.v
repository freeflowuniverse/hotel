module hoteldb

import freeflowuniverse.crystalib.params
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

pub struct Boat{
	ProductMixin
pub mut:
	boat_type            BoatType
	horsepower           int
	experience_required  ExperienceRequired
}

// TODO maybe do a function to calculate cost for fuel + time

pub fn (hdb HotelDB) add_boat (o params.Params) {

	boat := Boat{
		id : o.get('id')
		name : o.get('name')
		url : o.get('url')
		description : o.get('description')
		price : finance.amount_get(o.get('price'))
		state: match_state(o.get('state'))
		boat_type : match_boat_type(o.get('boat_type'))
		horsepower : o.get('horsepower').int()
		experience_required : match_experience_required(o.get('experience_required'))
	}

	hdb.products << boat
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