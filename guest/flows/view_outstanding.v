module flows


pub fn (actor GuestFlows) view_outstanding_flow (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	mut guest := actor.get_guest_from_telegram(ui.user_id)

	if guest.code == '' {
		ui.send_exit_message("Please request an employee to assist you with your outstanding balance. If you also register your telegram username with the employee, you will be able to access it here.")
		return
	}

	balance := guest.digital_funds
	ui.send_exit_message("Your outstanding balance is: ${balance.val}${balance.currency.name}.")
}