module employee

import freeflowuniverse.hotel.library.person

import time

pub struct Employee {
person.Person
mut:
	title   string
	actor_ids  []string
	shifts []Shift
	working bool
	holidays_remaining int
}

struct Shift {
	id string
	start time.Time
	end time.Time
	actor_id  string // actor id of role actor ie Reception or Bar
}




