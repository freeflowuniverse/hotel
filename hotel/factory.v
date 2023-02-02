module hotel

import freeflowuniverse.hotel.hotel.hoteldb {HotelDB}
import freeflowuniverse.crystallib.pathlib {Path}

import os

pub struct Hotel {
pub mut:
	name       string
	db         HotelDB
	db_path    Path
}

// TODO function to update exchange rates

pub fn new(name string, db_path_string string) !Hotel {
	mut hotel := Hotel{
		db: hoteldb.new() or {return error("Failed to create a new HotelDB")}
		name: name
		db_path: pathlib.get(db_path_string)
	}

	hotel.add_md_data(hotel.db_path.path) or {return error("Failed to read main db from $hotel.db_path.path: $err")}
	return hotel
}

pub fn (mut hotel Hotel) add_md_data (dir_path string) ! {
	hotel.db.add_md_data(mut pathlib.get(dir_path)) or {return error("Failed to populate database at path: ${dir_path}: \n$err")}
	hotel.set_db() or {return error("Failed to set db: $err")}
} 


pub fn (mut hotel Hotel) set_db () ! {
	hotel.write_products()!
	hotel.write_employees()!
	hotel.write_guests()!
}

pub fn (mut hotel Hotel) write_products () ! {
	file_path := hotel.db_path.join('products.md') or {return error("Failed to extend string: $err")}
	
	mut products_string := ''
	for product in hotel.db.products {
		products_string += "!!product
 code: '$product.code'
 name: '$product.name'
 price: '${product.price.val}${product.price.currency.name}'
 unit: '$product.unit'
 variable: '${product.variable.str()}'\n\n"
	}
	os.write_file(file_path.path, products_string)  or {return error("Failed to write products string to memdb")}
}

pub fn (mut hotel Hotel) write_employees () ! {
	file_path := hotel.db_path.join('employees.md') or {return error("Failed to extend string: $err")}
	
	mut employees_string := ''
	for employee in hotel.db.employees {
		employees_string += "!!employee
 id: '$employee.id'
 firstname: '$employee.firstname'
 lastname: '$employee.lastname'
 email: '$employee.email'
 telegram_username: '$employee.telegram_username'\n\n"
	}
	os.write_file(file_path.path, employees_string)  or {return error("Failed to write employees string to memdb")}
}

pub fn (mut hotel Hotel) write_guests () ! {
	file_path := hotel.db_path.join('guests.md') or {return error("Failed to extend string: $err")}
	
	mut guests_string := ''
	for guest in hotel.db.guests {
		guests_string += "!!guest
 code: '$guest.code'
 firstname: '$guest.firstname'
 lastname: '$guest.lastname'
 email: '$guest.email'
 telegram_username: '$guest.telegram_username'
 wallet: '${guest.wallet.val}${guest.wallet.currency.name}'
 hotel: '${guest.hotel_resident.str()}'\n\n"
	}
	os.write_file(file_path.path, guests_string)  or {return error("Failed to write guests string to memdb")}
}
