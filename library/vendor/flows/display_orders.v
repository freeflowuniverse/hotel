module flows

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.crystallib.ui

pub fn (flows IVendorFlows) display_orders (job ActionJob) {
	user_id := job.args.get('user_id')!
	channel_type := job.args.get('channel_type')!
	ui := ui.new(channel_type, user_id)

	mut orders := flows.get_vendor_orders(vendor.actor_name)! // list of orders

	open_bool := ui.ask_yesno("Do you want to see only open orders?")
	
	if open_bool {
		orders = orders.filter(it.status == .open)
	}

	mut orders_str := ''
	for order in orders {
		orders_str += order.stringify()
	}

	ui.send_exit_message("Open Orders:\n $orders_str")
}