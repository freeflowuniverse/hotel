module hoteldb

import freeflowuniverse.crystallib.params

pub struct Employee {
pub mut:
	id       string
	firstname  		  string
	lastname   		  string
	email             string
	telegram_username string
}

pub enum PersonStatus {
	unknown
	employee
	guest
}

pub fn (mut db HotelDB) get_user_status (username string) PersonStatus {
	// people are employees first and guests second
	for employee in db.employees {
		if employee.telegram_username ==username {
			return .employee
		}
	}
	for guest in db.guests {
		if guest.telegram_username == username {
			return .guest
		}
	} 
	return .unknown
}

// adds an employee from md files / actionparser
pub fn (mut db HotelDB) params_to_employee (mut o params.Params) ! {

	id := o.get('id') or {db.generate_employee_id()}

	employee := Employee{
		id : id
		firstname : o.get('firstname')!
		lastname : o.get('lastname')!
		email: o.get('email')!
		telegram_username: o.get('telegram_username')!
	}

	db.employees << employee
}

pub fn (db HotelDB) get_employee_by_telegram (username string) Employee {
	for employee in db.employees {
		if employee.telegram_username == username {
			return employee
		}
	}
	return Employee{}
}

fn (db HotelDB) generate_employee_id () string {
	mut greatest_id := 0
	for employee in db.employees {
		if employee.id.int() > greatest_id {
			greatest_id = employee.id.int()
		}
	}
	return (greatest_id + 1).str()
}