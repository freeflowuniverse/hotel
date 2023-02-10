module employee

import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.common

import time

pub struct Employee {
person.Person
mut:
	title   string
	actor_ids  []string
	shifts map[string]Shift // string is id
	working bool
	holidays_remaining int
	guest_orders map[string]common.Order
}

struct Shift {
	id string
	start time.Time
	end time.Time
	actor_id  string // actor id of role actor ie Reception or Bar
}

// send work schedule
// employees can call this function to see their work schedule for the upcoming week/month etc
// FROM USER
fn (employee Employee) get_work_schedule () ! {}

// check if on shift
// allows an internal system to see if this employee is currently working
// INTERNAL
fn (employee Employee) check_if_on_shift () ! {}

// clock in
fn (employee Employee) clock_in () ! {}

// clock out
fn (employee Employee) clock_out () ! {}

// schedule holiday
fn (employee Employee) schedule_holiday (days []time.Time) ! {}

// report sick
fn (employee Employee) report_sick (subject string) ! {}



