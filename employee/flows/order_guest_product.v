module flows

import freeflowuniverse.hotel.library.common
import freeflowuniverse.baobab.jobs {ActionJob}
import freelowuinverse.hotel.library.flow_methods
import freeflowuniverse.hotel.library.product


// ? for now it seems difficult to modify a product order
// it seems better to simply cancel an order and then resubmit, you will still need to go through the paces anyway.
fn (mut flows EmployeeFlows) order_guest_product (job ActionJob) {

	// var initializatiion
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)
	mut order := common.Order{}

	// get employee id
	mut employee_person := flow_methods.get_employee_person_from_handle(user_id, channel_type, flows.baobab) or {
		ui.send_exit_message("Failed to get employee identity from $channel_type username. Please try again later.")
		return
	}
	order.orderer_id = employee_person.id

	// get and validate guest code
	order.guest_code = ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: flow_methods.validate_guest_code
	)	
	order.for_id = guest_code

	// get product amounts for the order
	mut another_product := true
	product_loop: for another_product {

		mut product_amount := product.ProductAmount{}

		product_code := ui.ask_string(
			question: "What is the product code?"
			validation: flow_methods.validate_product_code
		)

		product_amount.quantity = ui.ask_string(
			question: "What quantity of this product do you want?"
			validation: fn (quantity string) bool {
				if quantity.int() > 0 { return true } 
				else { return false }
			}
		)

		product_availability = common.get_product(product_code)
		if product_availability.available == false {
			ui.send_message("That product is not available ")
			continue product_loop
		}
		product_amount.product := product_a.Product
		product_amount.price = product_amount.product.price.multiply(product_amount.quantity)

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

	successes, failures := common.split_send_wait_order(order, flows.baobab)! 
	if successes.len == 0 {
		ui.send_exit_message("Failed to place order, please try again later")
	} else if failures.len == 0 {
		ui.send_exit_message("Your order has been successfully placed.")
	} else {
		for failure in failures {
			ui.send_message(failure.stringify())
		}
		ui.send_exit_message("The above orders failed to be placed, the rest were successful.")
	}
}





