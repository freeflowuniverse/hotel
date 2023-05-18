module user_model

import time

pub struct Guest {
UserCore
}

pub struct Employee {
UserCore
pub mut:
	title   string
	actor_ids  []string
	shifts []Shift
	working bool
	holidays_remaining int
}

pub struct Shift {
	id string
	start time.Time
	end time.Time
	actor_id  string // actor id of role actor ie Reception or Bar
}

pub struct UserCore {
pub mut:
	telegram_username string
	id                string 
	firstname         string
	lastname          string
	email             string
	phone_number      string
	date_of_birth     time.Time
	allergies         []string
	preferred_contact string
	digital_funds     f64 //usd
}
