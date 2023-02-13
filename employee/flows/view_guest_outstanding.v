module flows

import freelowuinverse.hotel.library.flow_methods

pub fn (flows EmployeeFlows) guest_outstanding (job ActionJob) {
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	// ? is this necessary? validation question
	mut employee_person := flow_methods.get_employee_person_from_handle(user_id, channel_type, flows.baobab) or {
		ui.send_exit_message("Failed to get employee identity from $channel_type username. Please try again later.")
		return
	}
	
	guest_code := ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: flow_methods.validate_guest_code
		)

	balance := flows.get_guest(guest_code)!.digital_funds

	ui.send_exit_message("The guest's outstanding balance is: ${balance.val}${balance.currency.name}.")
}