module flows

import freeflowuniverse.hotel.employee

fn (flows ReceptionFlows) onboard_employee (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	mut registerer := flow_methods.get_employee_person_from_handle(user_id, channel_type, flows.baobab) or {
		ui.send_exit_message("Failed to get employee identity from $channel_type username. Please try again later.")
		return
	}

	mut employee := employee.Employee{}

	employee.firstname = ui.ask_string(
		question: "What is the employee's firstname?"
		)
	employee.lastname = ui.ask_string(
		question: "What is the employee's lastname?"
		)
	employee.email = ui.ask_string( // todo ask_email
		question: "What is the employee's email?"
	) 
	telegram_bool = ui.ask_yesno(
		question: "would you like to register a telegram username with this employee?"
	)
	if telegram_bool {
		employee.telegram_username = ui.ask_string(
			question: "What is the employee's telegram username?"
		)
	}

	mut roles := []string{}

	mut another_role := true
	for another_role {

		// todo get a list of all roles
		items := ['kitchen', 'bar', 'reception', 'hr']
		choice := ui.ask_dropdown(
			question: "What role do you want to assign to this employee?"
			items: items
		)
		roles << items[choice.int()-1]

		another_role = ui.ask_yesno(
			question: "Would you like to add another role?"
		)
	}

	flows.register(employee, employee.id, roles) or {
		ui.send_exit_message("Failed to register employee, please try again later.")
		return
	}

	ui.send_exit_message("$employee.firstname $employee.lastname has been successfully registered.")
}
