module flows

import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.jobs {ActionJob}

import json


pub fn (flows IVendorFlows) get_vendor_orders (vendor_name string, open bool) ! {
	mut j_args := params.Params{}
	j_args.kwarg_add('open', open.str())
			
	job := flows.baobab.job_new(
		action: 'hotel.${vendor_name}.send_orders' // ? should this be send_orders or get_orders
		args: j_args
	)!
	response := flows.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error("Failed to get order from ${vendor.actor_name}")
	}
	return json.decode([]Order, response.result.get('orders')!)!
}

pub fn (flows IVendorFlows) send_close_order (order_id string) !bool {
	j_args := params.Params{}
	j_args.kwarg_add('order_id', order_id)
	job := flows.baobab.job_new(
		action: 'hotel.${vendor.actor_name}.close_order'
		args: j_args
	)!
	response := flows.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return false
	}
	return true
}

pub fn (flows IVendorFlows) send_add_product (product product.Product) !string {
	mut j_args := params.Params{}
	j_args.kwarg_add('product', json.encode(product))
	mut job := flows.baobab.job_new(
		action: 'hotel.${vendor.actor_name}.add_product'
		args: j_args
	)!
	response := flows.baobab.job_schedule_wait(job, 100)!
	product_id := response.result.get('product_id')!
	if response.state == .done && product_id != '' {
		return product_id
	}
	return error("Failed to add product")
}
