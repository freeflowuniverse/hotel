module person

import time
import library

struct Person {
mut:
	id                string // ? Should this be the main unique identifier or should employees and guests also have unique identifiers?
	firstname         string
	lastname          string
	email             string
	telegram_username string
	phone_number      string
	date_of_birth     time.Time
	allergies         []string
	preferred_contact string
	digital_funds     library.Price //todo make sure there is only currency for digital funds ie dollars
}

// ! TODO move to person
fn (person Person) receive_transaction (mut job ActionJob) ! {
	transaction := job.args.get('transaction')

	actor.guests[transaction.sender]
	// todo send job back to employee

	//! THIS IS WHERE I AM SO FAR

	// todo I need to resolve the sender, receiver issue ie if a guest adds money to their digital funds are they the sender or receiver?
}

// fn (mut person Person) add_digital_funds(amount library.Price) ! {

// }

// fn (mut person Person) deduct_digital_funds(amount library.Price) {
	
// }