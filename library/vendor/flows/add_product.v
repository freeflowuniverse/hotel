module flows

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.flow_methods

pub fn (flows IVendorFlows) add_product (job ActionJob) {
	user_id := job.args.get('user_id')!
	channel_type := job.args.get('channel_type')!
	ui := ui.new(channel_type, user_id)

	new_product := product.Product{}

	product.name = ui.ask_string("What is the product's name?")
	product.description = ui.ask_string("What is the product's description?")
	state_bool = ui.ask_yesno("Is the product available for immediate use?")
	if state_bool == false {
		product.state = .planned
	}
	// todo change Unit enum to just a string
	product.unit = ui.ask_string("What unit does your product have? (for example, kg, ml, piece/unit, hour)")
	product.price = ui.ask_price("How much does a single unit of the product cost?")
	// todo figure out how to do ProductTags
	mut constituents_bool := ui.ask_yesno("Is this a physical product and do you have to prepare this product in the hotel?")

	product.variable_price = ui.ask_yesno("Does this product have a variable price?")
	
	for constituents_bool {

		mut product_amount := product.ProductAmount{}

		product_code := ui.ask_string(
			question: "What is the product code?"
			validation: flow_methods.validate_product_code // TODO
		)
		
		product_amount.quantity = ui.ask_string(
			question: "What quantity of this product is required?"
			validation: fn (quantity string) bool {
				if quantity.int() > 0 { return true } 
				else { return false }
			}
		)

		product_availability = common.get_product(product_code)

		product_amount.product := product_a.Product
		product_amount.price = product_amount.product.price.multiply(product_amount.quantity)

		product.constituent_products << product_amount

		constituents_bool = ui.ask_yesno(
			question: "Would you like to add another constituent product?"
		)
	}

	// todo product.stringify

	confirmation_bool := ui.ask_yesno("Would you like to confirm the addition of the following product?: \n ${product.stringify()}")

	if confirmation_bool == false  {
		ui.send_exit_messag("Your product addition has been cancelled. Please try again")
	}
	product_id := flows.send_add_product(product) or {
		ui.send_exit_message("Failed to add product to $vendor.actor_name")
	}
	ui.send_exit_message("Successfully added $product.name to $vendor.actor_name. It has been assigned the following ID: $product_id")
}
