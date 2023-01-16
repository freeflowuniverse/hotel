module hoteldb

import freeflowuniverse.crystallib.actionparser

pub const (
	purchase_log_path = 'purchase_log.txt'
)

pub fn (mut db HotelDB) populate (path string) ! {
	db.log_file = pathlib.get(purchase_log_path) // TODO check that this gets the correct path
	db.process(path) or {return error("Failed to process customers, products and log: $err")}
}

pub fn (mut db HotelDB) process(path string)!{
	ap := actionparser.get()
	ap.file_parse(path) or {return error("Failed to parse action directory: $err")}
	for action in ap.actions {
		
	}
	// TODO use actions to get customers and products
	// TODO use actions to pull the latest purchase_log.txt from github
}