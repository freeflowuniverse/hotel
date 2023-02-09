module reception

import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.hotel.library.person
import freeflowuniverse.baobab.jobs { ActionJob }

import time

fn (actor ReceptionActor) register_guest_flow (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	if user_id !in actor.employee_ids {
		ui.send_exit_message("This functionality is only available to reception employees.")
		return
	}

	mut guest := person.Person{}

	guest.firstname = ui.ask_string(
		question: "What is the guest's firstname?"
		)
	guest.lastname = ui.ask_string(
		question: "What is the guest's lastname?"
		)
	guest.email = ui.ask_string( // ? Should this be ask_email?
		question: "What is the guest's email?"
		validation: validate_email
	) 
	guest.hotel_resident = ui.ask_yesno(
		question: "Is the guest a resident of the hotel?"
	)
	telegram_bool = ui.ask_yesno(
		question: "would you like to register a telegram username with this guest?"
	)
	if telegram_bool {
		guest.telegram_username = ui.ask_string(
			question: "What is the guest's telegram username?"
		)
	}
	
	if guest_code := actor.register_guest(guest, employee_id) {
		ui.send_exit_message("$guest.firstname $guest.lastname has been successfully registered. Their guest code is: $guest_code")
	} else {
		ui.send_exit_message("Failed to register guest, please try again later.")
	}
}

fn (actor ReceptionActor) take_guest_payment_flow (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	if user_id !in actor.employee_ids {
		ui.send_exit_message("This functionality is only available to reception employees.")
		return
	}

	mut transaction := finance.Transaction{
		receiver: user_id
	}

	transaction.sender = ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: validate_guest_code
	)

	transaction.total_amount = ui.ask_string(
		question: "What amount is the guest's payment?"
		validation: validate_price
		)

	transaction.medium = match ui.ask_dropdown( // ? Should this be ask_email?
		question: "Through what medium is the guest making the payment?"
		items: ['cash', 'card', 'coupon', 'complimentary']
	) {
		1 {finance.TransactionMedium.cash}
		2 {finance.TransactionMedium.card}
		3 {finance.TransactionMedium.coupon}
		4 {finance.TransactionMedium.complimentary}
	}

	note_bool := ui.ask_yesno("Would you like to enter a note with this payment")

	if note_bool {
		transaction.note = ui.ask_string("Please enter the contents of your note:")
	}

	transaction.time_of = time.now()
	transaction.target_actor = 'guest'

	if actor.send_funds(transaction) {
		ui.send_exit_message("Succesfully added funds to the guest.")
	} else {
		ui.send_exit_message("Failed to add funds to guest.")
	}
}


// // purely financial transaction from a sender to receiver with full detail
// pub struct Transaction {
// mut:
// 	id string
// 	sender string // TODO define more precisely what this represents
// 	receiver string // TODO define more precisely what this represents
// 	total_amount Price
// 	medium TransactionMedium
// 	bank_transfer_details BankTransferDetails
// 	note string
// time_of time.Time
// 	completed bool
// }