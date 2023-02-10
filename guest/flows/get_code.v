module flows


pub fn (actor GuestFlows) get_code_flow (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	mut guest_code := actor.get_guest_from_telegram(ui.user_id).code

	if guest_code == '' {
		ui.send_exit_message("Please request an employee to assist you with your code. If you also register your telegram username with the employee, you will be able to access it here.")
		return
	} else {
		ui.send_exit_message("Your Guest Code is: $guest_code")
	}

}