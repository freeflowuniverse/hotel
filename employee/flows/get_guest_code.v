module flows

pub fn (flows EmployeeFlows) get_guest_code (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	// ? Do we want to log this?
	
	// ! validation has already occured at the flow supervisor actor, but maybe still useful
	//  if employee_id == '' {
	// 	ui.send_exit_message("This functionality is only available to employees.")
	// 	return
	// }

	firstname := ui.ask_string(
		question: "What is the guest's firstname?"
		)
	lastname := ui.ask_string(
		question: "What is the guest's lastname?"
		)
	email := ui.ask_string( // ? Should this be ask_email?
		question: "What is the guest's email?"
		validation: common.validate_email
	) 

	guest_code := flows.get_guest_code(firstname, lastname, email) or {
		ui.send_exit_message("A guest with those details could not be found.")
	}
	ui.send_exit_message("$firstname $lastname's code is $guest_code")
}