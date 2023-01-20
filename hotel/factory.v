module hotel

import freeflowuniverse.hotel.hotel.hoteldb {HotelDB}
import freeflowuniverse.crystallib.pathlib

pub struct Hotel {
pub mut:
	name  string
	db    HotelDB
}

pub fn new(name string, bot_token string) Hotel{
	mut p:= Hotel{
		name: name
		db: hoteldb.new()
	}
	return p
}

pub fn (mut hotel Hotel) generate_db (dir_path string) ! {
	hotel.db.populate(mut pathlib.get(dir_path)) or {return error("Failed to populate database at path: ${dir_path}: \n$err")}
}
