module hoteldb

import freeflowuniverse.crystallib.pathlib {Path}
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
	funds      map[string]finance.Amount // string is currency_name //TODO rename to hotel funds
	currencies finance.Currencies
	action_parser actionparser.ActionsParser
}

struct FailedAction {
	action   actionparser.Action
	error    string
}

pub fn new() !HotelDB {
	mut db := HotelDB{}
	db.currencies = finance.get_currencies(['TZS']) or {return error("Failed to get currencies: $err")}// TODO add whatever currencies necessary
	return db
}

pub fn (mut db HotelDB) add_md_data (mut dir_path Path) ! {
	file_paths := dir_path.file_list(recursive: true) or { return error("Failed to get list of files in given directory: $err") }
	for file_path in file_paths {
		db.process(file_path) or {return error("Failed to process $file_path.path with error: \n$err")}
	}
}

pub fn (mut db HotelDB) process (file_path Path) ! {
	mut ap := actionparser.get()
	ap.file_parse(file_path.path) or {return error("Failed to parse action directory: $err")}

	mut failed_actions := []FailedAction{}

	for mut action in ap.actions {
		match action.name.split('.')[0] {
			'allergen' {db.add_allergen(mut action.params) or {failed_actions << FailedAction{action, "Identified as allergen but failed to add: $err"}}}
			'product' {db.add_product(mut action) or {failed_actions << FailedAction{action, "Identified as product but failed to add: $err"}}}
			'customer' {db.add_customer(mut action.params) or {failed_actions << FailedAction{action, "Identified as customer but failed to add: $err"}}}
		 	else {failed_actions << FailedAction{action, "Failed to identify action"}}
		}
	}

	if failed_actions.len != 0 {
		println("hotelDB.process() was unable to add certain actions:")
		for action in failed_actions {
			println(action.action)
			println("Error: $action.error\n")
		}
	}
}
