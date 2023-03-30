module models

import freeflowuniverse.crystallib.money
import time

pub interface IUser {
UserCore
}

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
	user_type         UserType
	digital_funds     money.Money = money.get('0usd')!
}

pub enum UserType {
	guest
	employee
}
