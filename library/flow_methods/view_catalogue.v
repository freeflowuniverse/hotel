module flow_methods

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.product

pub struct ViewCatalogueMixin {}

pub fn (flows ViewCatalogueMixin) view_catalogue (job ActionJob) {
	
	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')
	ui := ui.new(channel_type, user_id)

	actors := [
		'kitchen',
		'bar',
	]

	mut choice := ui.ask_dropdown(
		question: "Which catalogue would you like to see?:"
		items: actors
		)

	actor_name := actors[choice.int()-1]

	avilable_products := common.get_catalogue([], actor_name, flows.baobab)!.products.filter(it.available==true)

	product_strs := []string{}
	for product in available_products {
		product_strs << product.short_str()
	}

	mut see_another := true
	for see_another {
		choice = ui.ask_dropdown(
			question: "If you would like to see a product in more detail, please send the corresponding number:"
			items: product_strs
		)

		product := available_products[choice.int()-1]

		ui.send_message(product.stringify())

		see_another = ui.ask_yesno("Would you like to return to the menu list?")
	}
	// todo ask if they want to apply filters
}