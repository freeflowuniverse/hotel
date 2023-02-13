module flows

import freeflowuniverse.hotel.library.finance
import freeflowuniverse.hotel.library.flow_methods


fn (flows ReceptionFlows) topup_guest_balance (job ActionJob) {

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

	transaction.total_amount = ui.ask_string( // todo ask_price
		question: "What amount is the guest's payment?"
		)

	transaction.medium = match ui.ask_dropdown(
		question: "Through what medium is the guest making the payment?"
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

	if flow_methods.send_transaction(transaction) {
		ui.send_exit_message("Succesfully added funds to the guest.")
	} else {
		ui.send_exit_message("Failed to add funds to guest.")
	}
}
