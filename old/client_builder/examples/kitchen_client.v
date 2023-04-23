module kitchen_client

import json

import freeflowuniverse.crystallib.params
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.supervisor_client

pub struct KitchenClient{
	kitchen_address string}

pub fn new(kitchen_id string) !KitchenClient {
	supervisor := supervisor_client.new("0")
	kitchen_address := supervisor.get_address("kitchen", kitchen_id)!
	return KitchenClient{
		baobab: baobab_client.new()
	}
}

pub fn (client KitchenClient) get_product (product_id string, ) !product.Product {
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

pub fn (client KitchenClient) get_products () ![]product.Product {
	j_args := params.Params{}
	job := flows.baobab.job_new(
		action: 'hotel.kitchen.get_products'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode([]product.Product, response.result.get('products')!)!
}

pub fn (client KitchenClient) root_flow (user_id string, ) !{
	j_args := params.Params{}
	j_args.kwarg_add('user_id', user_id)
	job := flows.baobab.job_new(
		action: 'hotel.kitchen.root_flow'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

