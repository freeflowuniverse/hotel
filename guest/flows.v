module guest

import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.baobab.jobs { ActionJob }

import time


// ? for now it seems difficult to modify a product order
// it seems better to simply cancel an order and then resubmit, you will still need to go through the paces anyway.
fn (mut actor GuestActor) order_product_flow (job ActionJob) {

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	mut order := common.Order{}

	order.for_id = actor.get_guest_from_telegram(flow.user_id).code
	order.orderer_id = actor.get_guest_from_telegram(flow.user_id).code
	
	if order.orderer_id == '' {
		ui.send_exit_message("Please register your telegram username at the reception.")
		return
	}
 
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


pub fn (actor GuestActor) get_code_flow (job ActionJob) {

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

pub fn (actor GuestActor) view_outstanding_flow (job ActionJob) {

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

pub fn (actor GuestActor) cancel_order_flow (job ActionJob) {
	
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	ui := ui.new(channel_type, user_id)

	mut guest := actor.get_guest_from_telegram(ui.user_id)
	
	if guest.code == '' {
		ui.send_exit_message("Please register your telegram username at the reception.")
		return
	}

	active_orders := actor.guests[guest_code].orders.filter(it.status=.open)

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

	actor.cancel_order_internal(active_orders[target_order_id])

	ui.send_exit_message("A cancel request has been made. We will get back to you shortly on whether your order can still be cancelled.")

	// todo will need to have a separate function that tells them whether their order has been cancelled or not
}
