module flows

pub fn (flows EmployeeFlows) guest_outstanding (job ActionJob) {
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	// ? is this necessary? validation question
	mut response := flows.get_employee_from_telegram(user_id)
	if response.state == .error{
		ui.send_exit_message("Failed to get employee identity from telegram username. Please try again later.")
		return
	}
	
	guest_code := ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: flows.validate_guest_code
		)

	balance := actor.get_guest_person(guest_code)!.digital_funds

	ui.send_exit_message("The guest's outstanding balance is: ${balance.val}${balance.currency.name}.")
}