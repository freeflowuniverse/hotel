module kitchen_client

import freeflowuniverse.hotel.library.common
import kitchen_model
import freeflowuniverse.hotel.library.product
import json
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.actors.supervisor.supervisor_client
import freeflowuniverse.crystallib.params

pub interface IClientKitchen {
	name string
	access_levels string
	storage_id string
	products []product.Product
	ingredients []product.Product
	telegram_channel string
	orders []common.Order
}

pub struct KitchenClient {
	kitchen_address string
	baobab          baobab_client.Client
}

pub fn new(kitchen_id string) !KitchenClient {
	supervisor := supervisor_client.new('0') or {
		return error('Failed to create a new supervisor client with error: ${err}')
	}
	kitchen_address := supervisor.get_address('kitchen', kitchen_id)!
	return KitchenClient{
		baobab: baobab_client.new()
	}
}

pub fn (kitchenclient KitchenClient) get_product(product_id string) !product.Product {
	j_args := params.Params{}
	j_args.kwarg_add('product_id', product_id)
	job := flows.baobab.job_new(
		action: 'hotel.kitchen.get_product'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode(product.Product, response.result.get('product')!)!
}

pub fn (kitchenclient KitchenClient) get_products() ![]product.Product {
	j_args := params.Params{}
	job := flows.baobab.job_new(
		action: 'hotel.kitchen.get_products'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode([]product.Product, response.result.get('product_list')!)!
}

pub fn (kitchenclient KitchenClient) order(order common.Order) ! {
	j_args := params.Params{}
	j_args.kwarg_add('order', json.encode(order))
	job := flows.baobab.job_new(
		action: 'hotel.kitchen.order'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

pub fn (kitchenclient KitchenClient) get() !IClientKitchen {
	j_args := params.Params{}
	job := flows.baobab.job_new(
		action: 'hotel.kitchen.get'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	if decoded := json.decode(kitchen_model.Kitchen, response) {
		return decoded
	}
	return error('Failed to decode kitchen type')
}
