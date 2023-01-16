module hoteldb

import freeflowuniverse.crystallib.pathlib

[heap]
pub struct HotelDB{
pub mut:
	products  []Product
	customers []Customer
	allergens []Allergen // ? Should this be so high level? Can i make it a constant or some other type
	log_file  pathlib.Path
}

pub fn new() HotelDB{
	mut p:= HotelDB{}
	return p
}
