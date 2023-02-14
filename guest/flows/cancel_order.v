module flows

import freeflowuniverse.hotel.library.common
import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.flow_methods

pub fn (flows GuestFlows) cancel_order (job ActionJob) {
	
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	guest_code := flows.get_guest_code_from_handle(user_id, channel_type) or {
		ui.send_exit_message("Failed to get guest identity from $channel_type username: $user_id. Please try again later.")
		return
	}

	active_orders := flow_methods.get_guest_active_orders(guest_code, flows.baobab)

	mut order_strings := []string{}
	orders_order := map[string]string{}

	mut count := 1
	for order in active_orders {
		order_strings << order.stringify()
		orders_order[count.str()] = order.id
		count += 1
	}

	choice := ui.ask_dropdown(
		question: "Please input the first number (not the ID) for the order you want to delete:"
		items: items // todo check that they stay in the correct order ie are not sorted on addition
	)
	target_order_id := orders_order[choice]

	confirmation := ui.ask_yesno("Are you sure you want to delete this order?")

	if confirmation == false {
		ui.send_message("No orders have been cancelled.") // todo how do we get them to redisplay the order selection. We could call flow again but that would go through the same calling process.
		return
	}
	ui.send_message("A cancel request has been made. We will get back to you shortly on whether your order has been cancelled.")
	
	common.cancel_wait_order(active_orders[target_order_id], flows.baobab) or {
		ui.send_message("Failed to cancel order. Please try again later.")
	}
	ui.send_message("Your order has been successfully cancelled.")
}
