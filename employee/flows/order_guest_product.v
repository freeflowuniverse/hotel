module flows

import freeflowuniverse.hotel.library.common
import freeflowuniverse.baobab.jobs {ActionJob}

// ? for now it seems difficult to modify a product order
// it seems better to simply cancel an order and then resubmit, you will still need to go through the paces anyway.
fn (mut flows EmployeeFlows) order_guest_product (job ActionJob) {

	// var initializatiion
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)
	mut order := common.Order{}

	// get employee id
	mut employee_person := flows.get_employee_from_telegram(user_id) or {
		ui.send_exit_message("Failed to get employee identity from telegram username. Please try again later.")
		return
	}
	order.orderer_id = employee_person.id

	// get and validate guest code
	order.guest_code = ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: flows.validate_guest_code
	)	
	order.for_id = guest_code

	// get product amounts for the order
	mut another_product := true
	product_loop: for another_product {

		mut product_amount := common.ProductAmount{}

		product_code := ui.ask_string(
			question: "What is the product code?"
			validation: flows.validate_product_code
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

	if common.forward_order([order], 'hotel.employee.guest_order', flows.baobab)! == true {
		ui.send_exit_message("Your order has been successfully placed.")
	} else {
		ui.send_exit_message("Your order failed. Please try again later")
	}
}





