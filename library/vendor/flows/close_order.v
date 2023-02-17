module flows

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.crystallib.ui

pub fn (flows IVendorFlows) close_order (job ActionJob) {
	user_id := job.args.get('user_id')!
	channel_type := job.args.get('channel_type')!
	ui := ui.new(channel_type, user_id)

	vendor_name := job.action.split('.')[1..2] // todo confirm the exact structure of job.action

	open_orders := flows.get_vendor_open_orders(vendor_name, true) // list of orders

	mut order_strs := []string{}
	for order in open_orders {
		order_strs << order.stringify()
	}

	choice := ui.ask_dropdown(
		question: "Please enter the Order ID you want to close:"
		items: order_strs
		)

	target_order := open_orders[choice.int()-1]
	if flows.send_close_order(target_order.id)! == true {
		ui.send_exit_message("Order successfully closed.")
	} else {
		ui.send_exit_message("Failed to successfully close")
	}
}