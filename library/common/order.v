module common

import freeflowuniverse.hotel.library.product

import time

// ORDER


// an exchange of goods or services with specific magnitude defined
pub struct Order {
pub mut:
	id string // unique per actor
	for_id string // who is the order for?
	orderer_id string // who made the order? employee or guest?
    start time.Time // desired time for order to arrive or for booking to start
	product_amounts []product.ProductAmountRef
	note string
	// additional_attributes []Attribute // extras like room service or for boat with captain or without captain
	order_status OrderStatus // open, closed, cancelled
	target_actor string
	canceller_id string // who cancelled the order? employee or guest? //? is there a better way to do this?
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

// pub fn (order Order) stringify () string {
// 	mut ordstr := 'Order ID: $order.id\nOrdered: ${order.start.relative()}\n'
// 	if order.note != '' {
// 		ordstr += 'Note: $order.note\n'
// 	}
// 	// if order.additional_attributes.len != 0 {
// 	// 	ordstr += 'Additional Attributes:\n'
// 	// 	for attr in order.additional_attributes {
// 	// 		ordstr += ' - ${attr.key.capitalize()}: $attr.value\n'
// 	// 	}
// 	// }
// 	ordstr += 'Products:\n'
// 	for pa in order.product_amounts {
// 		ordstr += ' - $pa.quantity x $pa.product.name\n'
// 	}
// 	return ordstr
// }

