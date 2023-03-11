module flows

import freeflowuniverse.hotel.library.flow_methods
import freeflowuniverse.crystallib.ui

pub fn (actor GuestFlows) view_outstanding_flow (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	guest_code := flows.get_guest_code_from_handle(user_id, channel_type) or {
		ui.send_exit_message("Failed to get guest identity from $channel_type username: $user_id. Please try again later.")
		return
	}

	mut guest_person := flow_methods.get_guest_person(guest_code) or {
		ui.send_exit_message("Failed to get full guest profile. Please try again later.")
		return
	}

	balance := guest_person.digital_funds
	ui.send_exit_message("Your outstanding balance is: ${balance.val}${balance.currency.name}.")
}