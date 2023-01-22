module hoteldb

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.pathlib {Path}

struct FailedAction {
	action   actionparser.Action
	error    string
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



// USING ACTIONRUNNER
// Look at gitunner, gitrunner_test and runner files in the actionrunner module


// pub fn new_runner() &Runner {
// 	// doesn't use factory since git init might specify separate config
// 	mut runner := Runner{
// 		channel: chan &ActionJob{cap: 100}
// 		channel_log: chan string{cap: 100}
// 	}
// 	return &runner
// }