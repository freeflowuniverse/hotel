module hotel

import freeflowuniverse.hotel.hotel.hoteldb {HotelDB}
import freeflowuniverse.crystallib.pathlib {Path}

import json
import os

pub struct Hotel {
pub mut:
	name       string
	db         HotelDB
	db_path    Path
}

pub fn new(name string, bot_token string, db_path_string string) !Hotel {

	mut hotel := Hotel{
		db: hoteldb.new() or {return error("Failed to create new HotelDB: $err")}
		name: name
		db_path: pathlib.get(db_path_string)
	}
	return hotel
}

pub fn (mut hotel Hotel) add_md_data (dir_path string) ! {
	hotel.db.add_md_data(mut pathlib.get(dir_path)) or {return error("Failed to populate database at path: ${dir_path}: \n$err")}
	hotel.set_db() or {return error("Failed to set db: $err")}
} 

pub fn get_db (db_path_string string) !HotelDB {
	db_path := pathlib.get(db_path_string)
	db_string := os.read_file(db_path.path) or {return error("Failed to read db from json file")}
	hotel_db := HotelDB{}
	if db_string != '' {
		mut hotel := json.decode(HotelDB, db_string) or {return error("Failed to decode json string")}
	}
	return hotel_db
}

pub fn (mut hotel Hotel) set_db () ! {
	db_string := json.encode(hotel.db)
	os.write_file(hotel.db_path.path, db_string) or {return error("Failed to write the db to json file")}
}

// TODO 
// pub fn (mut hotel Hotel) see_new_changes (dir_path string) ! {
// 	hotel_db := get_db(db_json_path.path)
// }
