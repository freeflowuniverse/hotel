module hoteldb

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.backoffice.finance

import os

const purchase_log_path = os.dir(@FILE) + '/purchase_log.txt'

[heap]
pub struct HotelDB{
pub mut:
	products   []Product
	customers  []Customer
	allergens  []Allergen // ? Should this be so high level? Can i make it a constant or some other type
	purchases  []Purchase
	currencies finance.Currencies
	action_parser actionparser.ActionsParser
}

pub fn new() !HotelDB {
	mut db := HotelDB{}
	db.currencies = finance.get_currencies(['TZS']) or {return error("Failed to get currencies: $err")}// TODO add whatever currencies necessary
	return db
}
