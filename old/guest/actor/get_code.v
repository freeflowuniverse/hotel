module flows

import freeflowuniverse.crystallib.ui
import freeflowuniverse.baobab.jobs {ActionJob}

pub fn (flows GuestFlows) get_code_flow (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	guest_code := flows.get_guest_code_from_handle(user_id, channel_type) or {
		ui.send_exit_message("Failed to get guest identity from $channel_type username: $user_id. Please try again later.")
		return
	}

	ui.send_exit_message("Your Guest Code is: $guest_code")
}