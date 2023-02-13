module common

import json
import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.product


// ORDER

enum Method {
	create
	modify
	delete
}

// an exchange of goods or services with specific magnitude defined
pub struct Order {
	id string
	for_id string
	orderer_id string // ? is this necessary? isnt it covered in the actionjob
    start time.Time // desired time for order to arrive or for booking to start
	product_amounts []product.ProductAmount
	note string
	method Method
	additional_attributes []Attribute
	completed bool
	target_actor string
	canceller_id string
}

// todo completed needs to be changed to status

/*
enum OrderStatus {
	open
	started
	finished
	cancelled
}
*/

// need to define a serializer for each order type

pub struct Attribute {
	key string
	value string
	value_type string //bool, int, f64
}


fn (order Order) stringify() string {
	mut ordstr := 'Order ID: $order.id\nTime: $order.start\n'
	if order.note != '' {
		ordstr += 'Note: $order.note\n'
	}
	if order.additional_attributes.len != 0 {
		ordstr += 'Additional Attributes:\n\n'
		for attr in order.additional_attributes {
			ordstr += '${attr.key.capitalize()}: $attr.value\n'
		}
	}
	ordstr += '\nProducts:\n\n'
	for pa in order.product_amounts {
		ordstr += '$pa.quantity x pa.product.name\n'
	}
	return ordstr
}

fn forward_order (order Order, action string, baobab client.Client) !([]Order, []Order) {
	j_args := params.Params{}
	j_args.kwarg_add('order', json.encode(order))
	job := baobab.job_new(
		action: action
		args: j_args
	)!
	response := baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error("Failed to place order")
	}
	successes := response.result.get('success_orders')
	failures := response.result.get('failure_orders')

	return successes, failures
}

fn forward_order_cancellation (order common.Order, action string, baobab client.Client) !string {
	
	j_args := params.Params{}
	j_args.kwarg_add('order', json.encode(order))
	job := actor.baobab.job_new(
		action: action
		args: j_args
	)!

	response := baobab.schedule_job_wait(job, 100)!

	if response.state == .done {
		return job.guid
	} else {
		return error("Failed to submit cancellation request")
	}
}

// todo function to return cancel_order