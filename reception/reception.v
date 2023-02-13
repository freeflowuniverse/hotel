module reception

import library.common

struct Reception {
	id string
	complaints map[string]common.Message
}

struct GuestRegistration {
	register_employee_id string
	guest_code string
	check_in time.Time
	check_in_employee_id string
	check_out time.Time
	check_out_employee_id string
}

