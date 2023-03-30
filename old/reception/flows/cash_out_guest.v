module flows

import freeflowuniverse.hotel.library.finance

fn (flows ReceptionFlows) cash_out_guest (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	mut employee_person := flow_methods.get_employee_person_from_handle(user_id, channel_type, flows.baobab) or {
		ui.send_exit_message("Failed to get employee identity from $channel_type username. Please try again later.")
		return
	}

	mut transaction := finance.Transaction{
		receiver: user_id
	}

	transaction.sender = ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: flow_methods.validate_guest_code
	)

	// todo who is transaction sender and receiver, ask alex about double entry bookkeeping

	guest_person := flow_methods.get_guest(transaction.sender, flows.baobab)

	ui.send_message("The guest's balance is $guest_person.balance.val $guest_person.balance.currency.name")

	transaction.total_amount := ui.ask_string( // todo ask_price
		question: "How much does the guest want to take out?"
		)

	// todo ensure everything is in usd

	if transaction.total_amount.val > guest_person.balance.val {
		transaction.total_amount.val = - guest_person.balance.val
		ui.send_message("That amount is too large, it has been moderated down to $guest_person.balance.val $guest_person.balance.currency.name, the guest's total balance")
	} else {
		transaction.total_amount.val = -transaction.total_amount.val
	}

	transaction.medium = match ui.ask_dropdown(
		question: "Through what medium is the guest taking the payment?"
		items: ['cash', 'card', 'coupon']
	) {
		1 {finance.TransactionMedium.cash}
		2 {finance.TransactionMedium.card}
		3 {finance.TransactionMedium.coupon}
	}

	note_bool := ui.ask_yesno("Would you like to enter a note with this payment")

	if note_bool {
		transaction.note = ui.ask_string("Please send your note:")
	}

	transaction.time_of = time.now()
	transaction.target_actor = 'guest'

	if finance.send_transaction(transaction)! == true {
		ui.send_exit_message("Succesfully removed funds from the guest.")
	} else {
		ui.send_exit_message("Failed to remove funds from guest.")
	}
}