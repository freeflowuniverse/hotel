module flows

import freeflowuniverse.baobab.jobs {ActionJob}

pub fn (Vendor[T]) display_orders (job ActionJob) {
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	orders := get_vendor_orders(T.name.to_lower, )

	open_bool := ui.ask_yesno("Do you want to see only open orders?")
}