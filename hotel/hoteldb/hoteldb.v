module hoteldb

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.actionparser

import os

const purchase_log_path = os.dir(@FILE) + '/purchase_log.txt'

[heap]
pub struct HotelDB{
pub mut:
	products  []Product
	customers []Customer
	allergens []Allergen // ? Should this be so high level? Can i make it a constant or some other type
	action_parser actionparser.ActionsParser
	log_file  pathlib.Path
}

pub fn new() HotelDB{
	mut db := HotelDB{}
	db.log_file = pathlib.get(hoteldb.purchase_log_path)
	return db
}
