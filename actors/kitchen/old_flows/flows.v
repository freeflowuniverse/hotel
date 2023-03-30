module kitchen

import freeflowuniverse.hotel.kitchen.kitchen_client
import freeflowuniverse.crystallib.ui.client as ui_client

fn root_flow (user_id string, kitchen_id string) ! {
	// todo do code generation for this
	flow_options := {
		0: 'order_flow'
	}
	response := ui.ask_dropdown("Which flow would you like to enter?", flow_options)
	
	match flow_options[response] {
		'order_flow' {order_flow(user_id)}
	}
}

// ideally you want UserActor acting as intermediary flow for this flow so that infrastructure for remote twins exists
// however this will require a lot of duplication of ideas to create the intermediary flows
// todo think about doing code generation for this intermediary flow
// this would mean that instead of creating a new ui_client, you would be creating a new user_client

/*
Order Flow:
1. create a new ui client
2. create a kitchen_client
3. get product offering
4. display product offering
5. user choose product
6. get product availability
7. display product availability
*/



fn order_flow (user_id string, kitchen_id string) ! {
	// where kitchen_id == R_01
	mut ui := ui_client.new(user_id, kitchen_id)
	kitchen_client := kitchen_client.new(kitchen_id)

	menu := kitchen_client.get_menu()
	ui.send_message(menu)
	product_code := ui.ask_question("What product do you want to order?")
	
	quantity_available := kitchen_client.check_availability(product_code)

	if quantity_available == 0 {
		ui.ask_question("Product not available, please enter another product_code")
	}

	quantity := ui.ask_question("What quantity do you want to order?", quantity_available)

	order := Order{
		product_code: product_code
		quantity: quantity
	}

	ui.send_message("Your order is being processed")

	ui.exit()

	kitchen_client.order(order)
}


fn get_guest (ui ui_client.Client) {
	// todo user_id 
}