module common

import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.common
import freeflowuniverse.crystallib.params

import time
import json

// ORDER


// an exchange of goods or services with specific magnitude defined
pub struct Order {
pub mut:
	id string
	for_id string
	orderer_id string // ? is this necessary? isnt it covered in the actionjob
    start time.Time // desired time for order to arrive or for booking to start
	product_amounts []product.ProductAmount
	note string
	additional_attributes []Attribute
	order_status OrderStatus
	target_actor string
	canceller_id string
}


pub enum OrderStatus {
	open
	closed
	cancelled
}

// need to define a serializer for each order type

pub struct Attribute {
	key string
	value string
	value_type string //bool, int, f64
}

// todo replace stringify method with stringify function

pub fn (order Order) stringify () string {
	mut ordstr := 'Order ID: $order.id\nOrdered: ${order.start.relative()}\n'
	if order.note != '' {
		ordstr += 'Note: $order.note\n'
	}
	if order.additional_attributes.len != 0 {
		ordstr += 'Additional Attributes:\n'
		for attr in order.additional_attributes {
			ordstr += ' - ${attr.key.capitalize()}: $attr.value\n'
		}
	}
	ordstr += 'Products:\n'
	for pa in order.product_amounts {
		ordstr += ' - $pa.quantity x $pa.product.name\n'
	}
	return ordstr
}

//! pub fn forward_order (order Order, action string, mut baobab client.Client) !([]Order, []Order) {
// 	mut j_args := params.Params{}
// 	j_args.kwarg_add('order', json.encode(order))
// 	mut job := baobab.job_new(
// 		action: action
// 		args: j_args
// 	)!
// 	response := baobab.job_schedule_wait(mut job, 100)!
// 	if response.state == .error {
// 		return error("Failed to place order")
// 	}
// 	successes := json.decode([]Order, response.result.get('success_orders')!)!
// 	failures := json.decode([]Order, response.result.get('failure_orders')!)!

// 	return successes, failures
// }

pub fn split_send_wait_order(order Order, mut baobab client.Client) !([]Order, []Order) {
	mut orders := map[string]common.Order{}
	for p_amount in order.product_amounts {
		actor_char := p_amount.product.id[0].ascii_str()
		if actor_char !in orders.keys() {
			orders[actor_char] = order
			orders[actor_char].product_amounts.clear()
		}
		orders[actor_char].product_amounts << p_amount
	}

	mut job_guids := []string{}

	for actor_char, mut order_ in orders {
		order_.target_actor = product.match_code_to_vendor(actor_char)!
		mut j_args := params.Params{}
		j_args.kwarg_add('order', json.encode(order_))
		mut n_job := baobab.job_new(
			action: 'hotel.${order.target_actor}.order'
			args: j_args
		)!
		baobab.job_schedule(mut n_job)!
		job_guids << n_job.guid
	}	

	mut successes := []common.Order{}
	mut failures := []common.Order{}

	for guid in job_guids {
		response := baobab.job_wait(guid, 10)!
		if response.state == .done {
			successes << json.decode(Order, response.args.get('order')!)!
		} else {
			failures << json.decode(Order, response.args.get('order')!)!
		}
	}
	return successes, failures
}

pub fn cancel_wait_order (order common.Order, mut baobab client.Client) ! {
	mut j_args := params.Params{}
	j_args.kwarg_add('order', json.encode(order))
	mut job := baobab.job_new(
		action: 'hotel.${order.target_actor}.cancel_order'
		args: j_args
	)!

	response := baobab.job_schedule_wait(mut job, 100)!

	if response.state != .done {
		return error("Failed to submit cancellation request")
	}
} 