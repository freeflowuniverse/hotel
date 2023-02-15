module guest

import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.common


// todo change maps to lists

pub struct Guest {
person.Person
pub mut:
	orders  []common.Order // string is id of order
	assistance_requests []common.AssistanceRequest  // string is id
	code    string
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


// request confirmation
// should receive an AssistanceRequest in return
// TODO fn (guest Guest) request_assistance (request common.AssistanceRequest) ! {}

