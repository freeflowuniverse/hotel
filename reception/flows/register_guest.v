module flows

fn (flows ReceptionFlows) register_guest (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	mut employee_person := flow_methods.get_employee_person_from_handle(user_id, channel_type, flows.baobab) or {
		ui.send_exit_message("Failed to get employee identity from $channel_type username. Please try again later.")
		return
	}

	mut guest := person.Person{}

	guest.firstname = ui.ask_string(
		question: "What is the guest's firstname?"
		)
	guest.lastname = ui.ask_string(
		question: "What is the guest's lastname?"
		)
	guest.email = ui.ask_string( // todo ask_email
		question: "What is the guest's email?"
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

	guest_code := flows.register(guest, employee.id) or {
		ui.send_exit_message("Failed to register guest, please try again later.")
		return
	}

	ui.send_exit_message("$guest.firstname $guest.lastname has been successfully registered. Their guest code is: $guest_code")
}
