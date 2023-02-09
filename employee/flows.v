module guest

import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.baobab.jobs { ActionJob }

import time

// todo will need to introduct state into guest actor to record channel type for certain jobs which wait for a response ie cancel_order

// ? for now it seems difficult to modify a product order
// it seems better to simply cancel an order and then resubmit, you will still need to go through the paces anyway.
fn (mut actor EmployeeActor) order_guest_product_flow (job ActionJob) {
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	mut order := common.Order{}

	order.orderer_id = actor.get_employee_from_telegram(flow.user_id).code
	
	if order.orderer_id == '' {
		ui.send_exit_message("This functionality is only available to employees.")
		return
	}

	order.guest_code = ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: actor.validate_guest_code
		)

	order.for_id = guest_code
 
	mut another_product := true

	for another_product {

		mut product_amount := hoteldb.ProductAmount{}

		product_code := ui.ask_string(
			question: "What is the product code?"
			validation: validate_product_code // TODO
		)

		product_amount.quantity = ui.ask_int(
			question: "What quantity of this product do you want?"
			validation: validate_quantity // TODO 
		)

		product_amount.product := actor.get_product(common.simple_catalogue_request([product_code]))!

		product_amount.price = finance.multiply(product_amount.product.price, product_amount.quantity)

		order.product_amounts << product_amount

		another_product = ui.ask_yesno(
			question: "Would you like to add another product?"
		)
	}

	now_bool := ui.ask_yesno("Do you want your order to arrive/start as soon as possible?")
	
	if now_bool == false {
		date := ui.ask_date("What day and month do you want your order to arrive/start?")
		time := ui.ask_time("What time do you want your order to arrive/start?")

		date_time := time.Time{
			year : time.now().year
			month : date['month']
			day: date['day']
			hour: time['hour']
			minute: time['minute']
		}

		order.start = date_time
	} else {
		order.start = time.now()
	}

	actor.order(order)! //? Should this be a method of the guest or a method of the GuestActor
}


pub fn (actor EmployeeActor) get_guest_code_flow (job ActionJob) {

	mut employee_id := actor.get_employee_from_telegram(flow.user_id).id
	
	if employee_id == '' {
		ui.send_exit_message("This functionality is only available to employees.")
		return
	}

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)
	
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

	guest_code := actor.get_guest_code(firstname, lastname, email) or {
		ui.send_exit_message("A guest with those details could not be found.")
	}
	ui.send_exit_message("$firstname $lastname's code is $guest_code")
}

pub fn (actor GuestActor) guest_outstanding_flow (job ActionJob) {
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	mut employee_id := actor.get_employee_from_telegram(flow.user_id).id
	
	if employee_id == '' {
		ui.send_exit_message("This functionality is only available to employees.")
		return
	}

	guest_code := ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: actor.validate_guest_code
		)

	mut guest_balance := actor.get_guest_balance(guest_code)!

	ui.send_exit_message("The guest's outstanding balance is: ${balance.val}${balance.currency.name}.")
}

pub fn (actor GuestActor) cancel_order_flow (job ActionJob) {
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
		validation: actor.validate_guest_code
	)

	active_orders := map[string]common.Order{}

	for employee in actor.employees {
		for order in employee.guest_orders {
			if order.for_id == guest_code && order.status = .open {
				active_orders << order
			}
		}
	}

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

	actor.cancel_order(active_orders[target_order_id])

	ui.send_exit_message("A cancel request has been made. We will get back to you shortly on whether your order can still be cancelled.")

	// todo will need to have a separate function that tells them whether their order has been cancelled or not
}