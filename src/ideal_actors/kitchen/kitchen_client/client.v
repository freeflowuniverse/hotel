module kitchen_client

import freeflowuniverse.hotel.library.common
import kitchen_model
import freeflowuniverse.hotel.library.product
import json
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.src.ideal_actors.supervisor.supervisor_client
import freeflowuniverse.crystallib.params

pub interface IClientKitchen {
mut:
	name string
	access_levels map[string][]string
	storage_id string
	products []product.Product
	ingredients []product.Product
	telegram_channel string
	orders []common.Order
}

pub struct KitchenClient {
pub mut:
	kitchen_address string
	baobab          baobab_client.Client
}

pub fn new(kitchen_id string) !KitchenClient {
	mut supervisor := supervisor_client.new() or {
		return error('Failed to create a new supervisor client with error: ${err}')
	}
	kitchen_address := supervisor.get_address('kitchen', kitchen_id)!
	return KitchenClient{
		baobab: baobab_client.new('0') or {return error("Failed to create new baobab client with error: \n$err")}
	}
}

pub fn (mut kitchenclient KitchenClient) get_product(product_id string) !product.Product {
	mut j_args := params.Params{}
	j_args.kwarg_add('product_id', product_id)
	mut job := kitchenclient.baobab.job_new(
		action: 'hotel.kitchen.get_product'
		args: j_args
	)!
	response := kitchenclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode(product.Product, response.result.get('product')!)!
}

pub fn (mut kitchenclient KitchenClient) get_products() ![]product.Product {
	mut j_args := params.Params{}
	mut job := kitchenclient.baobab.job_new(
		action: 'hotel.kitchen.get_products'
		args: j_args
	)!
	response := kitchenclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode([]product.Product, response.result.get('product_list')!)!
}

pub fn (mut kitchenclient KitchenClient) order(order common.Order) ! {
	mut j_args := params.Params{}
	j_args.kwarg_add('order', json.encode(order))
	mut job := kitchenclient.baobab.job_new(
		action: 'hotel.kitchen.order'
		args: j_args
	)!
	response := kitchenclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

pub fn (mut kitchenclient KitchenClient) get() !IClientKitchen {
	mut j_args := params.Params{}
	mut job := kitchenclient.baobab.job_new(
		action: 'hotel.kitchen.get'
		args: j_args
	)!
	response := kitchenclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	if decoded := json.decode(kitchen_model.Kitchen, response.result.get('encoded_kitchen')!) {
		return decoded
	}
	return error('Failed to decode kitchen type')
}
