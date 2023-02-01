module guest

import library.person
import library.common
import freeflowuniverse.crystallib.params

import json

struct Guest {
person.Person
mut:
	orders  map[string]common.Order // string is id
	assistance_requests map[string]common.AssistanceRequest  // string is id
}

// struct RestaurantRequests{}

// fn (r RestaurantRequests) expose_food_order_confirmation {
// 	order_type := params.get('order_type') // returns FoodOrder
// 	encoded_confirmation := params.get('order_confirmation')
// 	confirmation := json.decode(restaurant.FoodOrder, encoded_confirmation)!
// 	guest.confirmed_orders << confirmation
// 	// TODO send off params
// }

/*
Send Methods:
- order (this is to get a thing)
	- restaurant.bar (food, reservation) // ? should this be to waiter or to bar?
	- restaurant.kitchen (drinks)
	- dock (boat rentals)
	- spa (spa sessions)
	- room (rooms)
	- reception (miscellaneous objects - towels, converters, batteries. If not available request_assistance) 
	- reception.concierge (activity)
	- cleaning (request cleaning) //? should this go to room or to cleaning
	- cleaning.laundry (pickup)
- request_assistance
	- restaurant (waiter)
	- reception (report issue, transfer luggage, make change, procure item)
	- dock (boat issue)
	- reception.concierge (see more activities)
- get_product_selection
	- restaurant.kitchen 
	- restaurant.bar
	- dock 
	- spa 
	- room
	- cleaning.laundry 
	- reception.concierge (see standard activities)
- get_actor_details
	- most actors 
*/

// order product
// should receive a Transaction message in return
fn (guest Guest) order (order common.Order) ! {}

fn (guest Guest) expose_order_completed (params params.Params) ! {
	
	// order := common.params_to_order(params)
	// encoded_confirmation := params.get('order_confirmation')
	// confirmation := json.decode(common.Order, encoded_confirmation)!

	confirmation := json.decode(common.Order, params.get('order'))

	guest.confirmed_orders << confirmation
	// TODO send off params
}

// ! currently I have managed to find a set off 

// request confirmation
// should receive an AssistanceRequest in return
fn (guest Guest) request_assistance (request common.AssistanceRequest) ! {}

// get info
// should receive ProductCatalogue in return 
fn (guest Guest) get_product_catalogue (request CatalogueRequest) ! {}

// need to create an expose_info_response but one for each possible response
