module kitchen

import freeflowuniverse.hotel.actors.supervisor.supervisor_client
import freeflowuniverse.hotel.actors.kitchen.kitchen_client
import freeflowuniverse.crystallib.ui.client as ui_client
import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.actors.user
import freeflowuniverse.hotel.library.common

import time


pub struct KitchenFlow {
pub mut:
	ui ui_client.Client
	kitchen kitchen_client.Client
	supervisor supervisor_client.Client
	user user.User
}

fn root_flow (kitchen_id string, user_id string) ! {
	mut flow := KitchenFlow{
		ui: ui_client.new('kitchen', kitchen_id, user_id)!
		kitchen: kitchen_client.new(kitchen_id)!
		supervisor: supervisor_client.new(0)
	}

	if user, user_type := flow.supervisor.find_user(user_id, 'id') {
		flow.user = user
	} else {
		return error("User not recognised. This should never happen!")
	}

	mut items := ['order', 'exit']

	items << match flow.user.user_type {
		.guest { ['submit_complaint'] }
		.employee { ['change_menu'] }
	}

	int_choice := flow.ui.ask_dropdown(
		question: 'Please enter your choice for where to navigate to next:'
		items: items
	)

	choice := items[int_choice]
	match choice {
		'order' { flow.order() }
		'submit_complaint' { flow.submit_complaint() }
		'change_menu' { flow.change_menu() } 
		'exit' { println("This functionality has not yet been added!") }
		else {
			return error("This should never happen!")
		}
	}

	root_node(kitchen_id, user_id)
}

pub struct OrderFlow {
KitchenFlow
pub mut:
	order common.Order
	product_amount product.ProductAmount
}

fn (flow KitchenFlow) order () {
	mut of := OrderFlow{
		KitchenFlow: flow
	}

	if of.user.user_type == .employee { of.enter_guest_code() } 
	else { of.order.for_id = of.user.id }

	of.enter_product_amount()
	of.enter_order_time()
	
	of.kitchen.order(order)!
}

fn (mut of OrderFlow) enter_guest_code () {
	guest_id := flow.ui.ask_string("What is the guest's four letter ID?")
	
	if user, user_type := supervisor_client.find_user(guest_id, 'id') {
		of.order.for_id = user.id
	} else {
		of.ui.send_message("Guest ID not recognised!")
		of.enter_guest_code()
	}
}

fn (mut of OrderFlow) enter_product_amount () {
	of.product_amount = ProductAmount{}

	of.enter_product_id()
	of.enter_product_quantity()

	of.product_amount.total_price = of.product_amount.product.price.multiply(of.product_amount.quantity)

	if flow.user.user_type == .employee { of.enter_discount() }
	
	of.order.product_amounts << of.product_amount

	if of.ui.ask_yesno("Do you want to add another product?") {
		of.add_product_amount()
	}
}

fn (mut of OrderFlow) enter_product_id () {
	kitchen_products := of.kitchen.get_products()

	of.ui.send_message(stringify(kitchen_products))

	product_id = of.ui.ask_question("Please enter the product id of the item you wish to order?")

	products := kitchen_products.filter(it.id==product_id)

	if products.len == 0 {
		of.ui.send_message("Invalid product code! Please input a product code displayed in the menu.")
		of.enter_product_id()
	} else {
		of.product_amount.product = products[0]
	}
}

fn (mut of OrderFlow) enter_product_quantity () {
	of.product_amount.quantity = of.ui.ask_question("What quantity of this product do you want?")

	if of.product_amount.quantity.int() <= 0 {
		of.ui.send_message("Invalid quantity, please enter an integer greater than or equal to 1!")
		of.enter_product_quantity()
	}
}

fn (mut of OrderFlow) enter_discount () {
	discount := of.ui.ask_question("What percentage discount would you like to apply to this product? Please enter a number between 0 and 100.").int()

	if discount > 100 || discount < 0 {
		of.ui.send_message("Invalid input, please enter a number between 0 and 100.")
		of.enter_discount()
	} else {
		of.product_amount.total_price = of.product_amount.total_price.multiply(1-(discount/100))
	}
}

fn (mut of OrderFlow) enter_order_time () {
	now_bool := flow.ui.ask_yesno("Do you want your order to arrive/start as soon as possible?")

	if now_bool == false {
		of.order.start = time.now()
		return
	} 

	date := flow.ui.ask_date("What day and month do you want your order to arrive/start?")
	println(date)
	time := flow.ui.ask_time("What time do you want your order to arrive/start?")
	println(time)
	// date_time := time.Time{
	// 	year : time.now().year
	// 	month : date['month']
	// 	day: date['day']
	// 	hour: time['hour']
	// 	minute: time['minute']
	// }

	of.order.start = time.now()
}