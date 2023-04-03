module kitchen

import freeflowuniverse.hotel.actors.supervisor.supervisor_client
import freeflowuniverse.hotel.actors.kitchen.kitchen_client
import freeflowuniverse.crystallib.ui.client as ui_client
import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.actors.user
import freeflowuniverse.hotel.library.common

import time

struct KitchenFlow {
mut:
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

	mut items := ['order', 'exit', 'view_menu']

	items << match flow.user.user_type {
		.guest { ['submit_complaint'] }
		.employee { ['modify_menu'] }
	}

	int_choice := flow.ui.ask_dropdown(
		question: 'Please enter your choice for where to navigate to next:'
		items: items
	)

	choice := items[int_choice]
	match choice {
		'order' { flow.order() }
		'view_menu' {flow.view_menu()}
		'modify_menu' { flow.modify_menu() } 
		'submit_complaint' { flow.submit_complaint() }
		'exit' { println("This functionality has not yet been added!") }
		else {
			return error("This should never happen!")
		}
	}

	root_node(kitchen_id, user_id)
}

struct OrderFlow {
KitchenFlow
mut:
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
	date_time := time.Time{
		year : time.now().year
		month : date['month']
		day: date['day']
		hour: time['hour']
		minute: time['minute']
	}

	of.order.start = date_time
}

struct ViewMenuFlow {
KitchenFlow
mut:
	products []Product // ? maybe change to ProductAmount
	product_id string
}

fn (mut flow KitchenFlow) view_menu () {
	mut vmf := ViewMenuFlow{
		KitchenFlow: flow
	}

	vmf.products = vmf.kitchen.get_products()
	menu := products.map(it.short_str()).join('')
	vmf.ui.send_message(products.menu())
	vmf.view_product()
}

fn (mut vmf ViewMenuFlow) view_product () {
	view_bool := vmf.ui.ask_yesno("Would you like to view a product in more detail?")
	if view_bool {
		vmf.get_product_id()
		vmf.ui.send_message(vmf.products.filter(it.id==vmf.product_id)[0].stringify())
		vmf.view_product()
	}
}

fn (mut vmf ViewMenuFlow) get_product_id () {
	vmf.product_id = vmf.ui.ask_string("Please enter the ID of the product you would like to view:")
	if vmf.products.filter(it.id==vmf.product_id).len == 0 {
		vmf.ui.send_message("ID not recognised. Please input an ID displayed in the list above")
		vmf.get_product_id()
	} 
}

struct ModifyMenuFlow {
KitchenFlow
mut:
	products []Product // todo make sure all imports are done
	product Product
}

fn (mut flow KitchenFlow) modify_menu () {
	mut mmf := ModifyMenuFlow{
		KitchenFlow: flow
	}

	mmf.products = mmf.kitchen.get_products()
	mmf.perform_modification()
}

fn (mut mmf ModifyMenuFlow) perform_modification () {
	add_bool := mmf.ui.ask_yesno("Would you like to add a new product to the menu (as opposed to updating an existing product) ?")
	if create_bool {
		mmf.add_product()
	} else {
		mmf.update_product()
	}
	mmf.product = Product{}
	another_bool := mmf.ui.ask_yesno("Would you like to perform another modification?")
	if another_bool {
		mmf.perform_modification()
	}
}

/*
pub struct Product {
pub mut:
    id string // two digit number
    name string
	description string
    state ProductState
    price money.Money
    unit Unit
	tags []ProductTag
	constituent_products []ProductAmount
	variable_price bool
}
*/

fn (mut mmf ModifyMenuFlow) add_product () {
	mmf.ui.send_message("You have chosen to add a new product!")
	mmf.product.name = mmf.ui.ask_string("What is the name of the product?")
	mmf.product.description = mmf.ui.ask_string("Please give a description of the product?")

	if mmf.ui.ask_yesno("Is the product currently ready to be offered?") == false {
		mmf.product.state = .planned
	}

	units := mmf.product.unit.all()
	choice := mmf.ui.ask_dropdown(
		question: "Which unit does your product have?"
		items: units.map(it.str())
	)
	mmf.product.unit == units[choice]
	mmf.add_price()
	mmf.add_tag()
	mmf.add_constituent_product()
}

fn (mut mmf ModifyMenuFlow) add_price () {
	price_string := mmf.ui.ask_string("What is the price of this product? Please enter a price with both a number and a currency code.")
	if price := money.amoung_get(price_string) {
		mmf.product.price == price
	} else {
		ui.send_message("Price not identified: ${err}. Please try again.")
		mmf.add_price()
	}
}

fn (mut mmf ModifyMenuFlow) add_tag () {
	tag_bool := mmf.ui.ask_yesno("Would you like to add a tag to this product?")
	if tag_bool {
		tag_name := mmf.ui.ask_string("Please enter the tag name:")
		
		if mmf.product.tags.filter(it.name == tag_name).len > 0 {
			mmf.ui.send_message("A tag with this name already exists")
		} else {
			mmf.product.tags << CompanyTag{
				name: tag_name
			}
		}
		mmf.add_tag()
	} 
}

fn (mut mmf ModifyMenuFlow) add_constituent_product () {
	another_bool := mmf.ui.ask_yesno("Would you like to add a constituent product?")
	if another_bool {
		items := mmf.product.map(it.name)
		mmf.ui.ask_dropdown(
			question: "Which of the following products would you like to add as a constituent product?"
			items:
		)
	}
	// todo ask if they want to add a constituent product
	// todo get the product with ask_dropdown
	// todo ask for the quantity of that product
	// todo calculate total_price

}

// todo check how to access the attributes of a v struct
fn (mut mmf ModifyMenuFlow) update_product () {
	
}
