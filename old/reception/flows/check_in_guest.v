module flows

import freeflowuniverse.hotel.library.flow_methods

fn (flows ReceptionFlows) check_in_guest (job ActionJob) {
	mut employee_person := flow_methods.get_employee_person_from_handle(user_id, channel_type, flows.baobab) or {
		ui.send_exit_message("Failed to get employee identity from $channel_type username. Please try again later.")
		return
	}

	guest_code = ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: flow_methods.validate_guest_code
	)

	// todo take special requests

	flows.check_in(employee_person.id, guest_code)
}