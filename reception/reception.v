module reception

import freeflowuniverse.hotel.library.common

import time

pub struct GuestRegistration {
pub mut:
	employee_id string
	guest_code string
	// todo move to a different struct or move to accomodation
	check_in time.Time
	check_in_employee_id string
	check_out time.Time
	check_out_employee_id string
}

