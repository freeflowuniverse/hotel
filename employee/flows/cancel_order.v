module flows

pub fn (actor EmployeeFlows) cancel_order (job ActionJob) {
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	mut employee := actor.get_employee_from_telegram(ui.user_id)
	
	if employee_id == '' {
		ui.send_exit_message("This functionality is only available to employees.")
		return
	}

	guest_code := ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: flows.validate_guest_code
	)

	active_orders := flows.get_guest_orders(guest_code)

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
		ui.send_exit_message("No orders have been cancelled.") // todo how do we get them to redisplay the order selection. We could call flow again but that would go through the same calling process.
		return
	}	
	
	action := 'hotel.employee.cancel_guest_order'

	if common.cancel_order(active_orders[target_order_id], action, flows.baobab)! == true {
		ui.send_exit_message("A cancel request has been made. We will get back to you shortly on whether your order can still be cancelled.")
	} else {
		ui.send_exit_message("Failed to submit cancel request. Please try again later")
	}
}