module person

import time
import finance

struct Person {
	id                string // ? Should this be the main unique identifier or should employees and guests also have unique identifiers?
	firstname         string
	lastname          string
	email             string
	telegram_username string
	phone_number      string
	date_of_birth     time.Time
	allergies         []string
	preferred_contact string
	digital_funds     []finance.Amount
}

pub struct MoneyReceipt {
	subject     string
	sender      string // actor_id.instance_id (instance_id is optional)
	recipient   string // actor_id.instance_id (instance_id is optional)
	amount      finance.Amount
	description string
	time        time.Time
	employee_id string
}

fn (mut person Person) add_digital_funds(amount finance.Amount) ! {

}

fn (mut person Person) deduct_digital_dunds(amount finance.Amount) {
	
}