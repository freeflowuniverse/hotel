module hoteldb

import freeflowuniverse.crystallib.pathlib {Path}
import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.hotel.finance

// todo clear data_add after added
// todo make sure there is @ in email

import os

const purchase_log_path = os.dir(@FILE) + '/purchase_log.txt'

[heap]
pub struct HotelDB{
pub mut:
	products   []Product
	guests   []Guest
	employees []Employee
	currencies finance.Currencies
	action_parser actionparser.ActionsParser
}

struct FailedAction {
	action   actionparser.Action
	error    string
}

pub fn new() !HotelDB {
	mut db := HotelDB{}
	db.currencies = finance.get_currencies() or {return error("Failed to get currencies: $err")}// TODO add whatever currencies necessary
	return db
}

pub fn (mut db HotelDB) add_md_data (mut dir_path Path) ! {
	file_paths := dir_path.file_list(recursive: true) or { return error("Failed to get list of files in given directory: $err") }
	for file_path in file_paths {
		db.process(file_path) or {return error("Failed to process $file_path.path with error: \n$err")}
	}
}

fn (mut db HotelDB) process (file_path Path) ! {
	mut ap := actionparser.get()
	ap.file_parse(file_path.path) or {return error("Failed to parse action directory: $err")}

	mut failed_actions := []FailedAction{}

	for mut action in ap.actions {
		match action.name.split('.')[0] {
			'product' {db.params_to_product(mut action.params) or {failed_actions << FailedAction{action, "Identified as product but failed to add: $err"}}}
			'guest' {db.params_to_guest(mut action.params) or {failed_actions << FailedAction{action, "Identified as guest but failed to add: $err"}}}
			'employee' {db.params_to_employee(mut action.params) or {failed_actions << FailedAction{action, "Identified as employee but failed to add: $err"}}}
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
