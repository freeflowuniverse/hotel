module kitchen

import freeflowuniverse.crystallib.ui.client as ui_client
import freeflowuniverse.hotel.user
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.kitchen.kitchen_client

import time

pub struct KitchenFlow {
	ui ui_client.Client
	user user.User
	kitchen kitchen_client.Client
}

fn root_node (kitchen_id string, user_id string) ! {
	// ROOT INIT START
	mut flow := KitchenFlow{
		ui: ui_client.new('kitchen', kitchen_id, user_id)!
		kitchen: kitchen_client.new(kitchen_id)!
	}

	if user, user_type := supervisor_client.find_user(user_id, 'id') {
		flow.user = user
	} else {
		return error("User not recognised. This should never happen!")
	}
	// ROOT INIT END

	// ASK MATCH CHOICE START

	mut items := ['order', 'exit']

	match flow.user.user_type {
		.guest {
			items << ['submit_complaint']
		}
		.employee {
			items << ['change_menu']
		}
	}

	int_choice := flow.ui.ask_dropdown(
		question: 'hardcoded string'
		items: items
	)

	choice := items[int_choice]

	// ASK MATCH CHOICE END

	// DO ROUTE MATCH START

	match choice {
		'order' {
			// ROUTE START
			flow.order_node()
			// ROUTE END
		}
		'submit_complaint' {
			flow.submit_complaint_node()
		}
		'change_menu' {
			flow.change_menu_node()
		} else {
			return error("This should never happen!")
		}
	}

}

fn (flow KitchenFlow) order_node () {
	mut order := common.Order{}

	match flow.user.user_type {
		.guest {
			flow.initialize_guest_order_node (mut order)
		}
		.employee {
			flow.initialize_employee_order_node(mut order)
		}
	}
}


fn (flow KitchenFlow) initialize_employee_order_node (mut order common.Order) {
	guest_id := flow.ui.ask_string("What is the guest's four letter ID?")
	
	if user, user_type := supervisor_client.find_user(guest_id, 'id') {
		order.for_id = user.id
		flow.choose_new_product_node(mut order)
	} else {
		flow.ui.send_message("Guest ID not recognised!")
		flow.initialize_employee_order_node(mut order)
	}
}

fn (flow KitchenFlow) initialize_guest_order_node (mut order common.Order) {
	order.for_id = flow.user.id
	flow.choose_new_product_node(mut order)
}

fn (flow KitchenFlow) choose_new_product_node (mut order common.Order) {
	menu := flow.kitchen.get_products() // todo maybe take a param for the format?
	flow.ui.send_message(menu)
	product_id := ui.ask_question("What product do you want to order?")

	// todo this validation should be varied according to specific structure
	if product_id in menu.product_ids {
		product_amount := product.ProductAmount{
			product_id: product_id
		}
		flow.choose_product_quantity_node(mut order, mut product_amount)
	} else {
		flow.ui.send_message("Invalid product code! Please input a product code displayed in the menu.")
		flow.choose_new_product_node(mut order)
	}
}

fn (flow KitchenFlow) choose_product_quantity_node (mut order common.Order, mut product_amount product.ProductAmount) {
	quantity = flow.ui.ask_string(
		question: "What quantity of this product do you want?"
	)
	if quantity.int() > 0 {
		product_amount.quantity = quantity
		flow.check_product_availability_node(mut order, mut product_amount)
	} else {
		flow.ui.send_message("Invalid quantity, please enter an integer greater than or equal to 1!")
		flow.choose_product_quantity_node(mut order, mut product_amount)
	}
}

fn (flow KitchenFlow) check_product_availability_node (mut order common.Order, mut product_amount product.ProductAmount) {
	product_availability := flow.kitchen.get_product(product_amount.id)

	if product_availability.amount > quantity {
		flow.ui.send_message("This product is available in the quantity specified.")
		flow.determine_product_price_node(mut order, mut product_amount)
		// todo check that this is a valid operation
		product_amount.price = multiply(quantity, product_availability.price)
	} else {
		flow.ui.send_message("This product is not available in the quantity specified! This item has been removed from your order.")
		flow.choose_new_product(mut order)
	}
}

fn (flow KitchenFlow) determine_product_price_node (mut order common.Order, mut product_amount product.ProductAmount) {
	match flow.user.user_type {
		.guest {
			flow.complete_product_amount_node(mut order, mut product_amount)
		}
		.employee {
			flow.check_variable_price_node(mut order, mut product_amount)
		}
	}
}


fn (flow KitchenFlow) check_variable_price_node (mut order common.Order, mut product_amount product.ProductAmount) {
	variable_bool := flow.ui.ask_yesno("Would you like to choose a variable price")
	if variable_bool {
		flow.get_variable_price_node(mut order, mut product_amount)
	} else {
		flow.complete_product_amount_node(mut order, mut product_amount)
	}
}

fn (flow Kitchen Flow) get_variable_price_node (mut order common.Order, mut product_amount product.ProductAmount) {
	price_string := flow.ui.ask_question("The current cost of the ${quantity} units of this product is ${product_amount.price.val}${product_amount.price.currency.name}. What would you like the new price to be?")
	if price := finance.amount_get(price_string) {
		product_amount.price = price
		flow.complete_product_amount_node(mut order, mut product_amount)
	} else {
		flow.ui.send_message("The price you inputted was not recognised.")
		flow.get_variable_price_node(mut order, mut product_amount)
	}
}

fn (flow KitchenFlow) complete_product_amount_node (mut order common.Order, mut product_amount product.ProductAmount) {
	order.product_amounts << product_amount
	another_bool := flow.ui.ask_yesno("Would you like to add another product?")
	if another_bool {
		flow.choose_new_product_node(mut order)
	} else {
		flow.schedule_order_node (mut order)
	}
}

fn (flow KitchenFlow) schedule_order_node (mut order common.Order) {
	now_bool := flow.ui.ask_yesno("Do you want your order to arrive/start as soon as possible?")

	if now_bool {
		flow.ask_date_node(mut order)
	} else {
		//? Should I pass in time.now() here or should there be a separate node to run that command
		flow.set_due_node(mut order, time.now())
	}
}

fn (flow KitchenFlow) ask_date_node (mut order common.Order) {
	date := flow.ui.ask_date("What day and month do you want your order to arrive/start?")
	time := flow.ui.ask_time("What time do you want your order to arrive/start?")
	
	date_time := time.Time{
		year : time.now().year
		month : date['month']
		day: date['day']
		hour: time['hour']
		minute: time['minute']
	}
	flow.set_due_node(mut order, date_time)
}

fn (flow KitchenFlow) set_due_node (mut order common.Order, start_time time.Time) {
	order.start = start_time
	flow.submit_order_node(mut order)
}

fn (flow KitchenFlow) submit_order_node(mut order common.Order) {
	flow.kitchen.order(order)!
	// todo what next?
}