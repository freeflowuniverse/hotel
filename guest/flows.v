module interface

import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.hotel.hoteldb
import library.common
import library.finance

import time


struct Flow {
	ui ui.UserInterface
}

// ? for now it seems difficult to modify a product order
// it seems better to simply cancel an order and then resubmit, you will still need to go through the paces anyway.
fn (mut actor GuestActor) order_product_flow () {

	mut order := common.Order{}

	order.orderer_id := actor.get_guest_from_telegram(flow.user_id).code
	
	if order.orderer_id == '' {
		actor.flow.ui.send_exit_message("Please register your telegram username at the reception.")
		return
	}
 
	mut another_product := true

	for another_product {

		mut product_amount := hoteldb.ProductAmount{}

		product_code := actor.flow.ui.ask_string(
			question: "What is the product code?"
			validation: validate_product_code // TODO
		)

		product_amount.quantity = actor.flow.ui.ask_int(
			question: "What quantity of this product do you want?"
			validation: validate_quantity // TODO 
		)

		product_amount.product := actor.get_product(common.simple_catalogue_request([product_code]))!

		product_amount.price = finance.multiply(product_amount.product.price, product_amount.quantity)

		order.product_amounts << product_amount

		another_product = actor.flow.ui.ask_yesno(
			question: "Would you like to add another product?"
		)
	}

	order.order_time = time.now()

	actor.order(order)! //? Should this be a method of the guest or a method of the GuestActor
}


pub fn (actor GuestActor) get_code_flow () {

	mut guest_code := actor.get_guest_from_telegram(flow.user_id).code

	if guest_code == '' {
		actor.flow.ui.send_exit_message("Please request an employee to assist you with your code. If you also register your telegram username with the employee, you will be able to access it here.")
		return
	} else {
		actor.flow.ui.send_exit_message("Your Guest Code is: $guest_code")
	}

}

pub fn (actor GuestActor) view_outstanding_flow () {

	mut guest := actor.get_guest_from_telegram(flow.user_id)

	if guest.code == '' {
		actor.flow.ui.send_exit_message("Please request an employee to assist you with your outstanding balance. If you also register your telegram username with the employee, you will be able to access it here.")
		return
	}

	balance := guest.digital_funds
	actor.flow.ui.send_exit_message("Your outstanding balance is: ${balance.val}${balance.currency.name}.")
}

pub fn (actor GuestActor) cancel_order_flow () {
	
	mut guest := actor.get_guest_from_telegram(flow.user_id)
	
	if guest.code == '' {
		actor.flow.ui.send_exit_message("Please register your telegram username at the reception.")
		return
	}

	// todo get active orders
	// todo actor.flow.ui.ask_dropdown for active orders 
	// todo ask if they are sure they want to delete the order
	// todo send message that cancel_request has been sent
	// todo will need to have a separate function that tells them whether their order has been cancelled or not
}