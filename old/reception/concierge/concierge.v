module concierge

import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.common


struct Concierge {
	id string
	external_activities []product.Product
	guest_orders []common.Order
}

// 
fn (mut concierge Concierge) confirm_order_booked () ! {}

fn (mut concierge Concierge) expose_order() ! {}

fn (mut concierge Concierge) () ! {}
