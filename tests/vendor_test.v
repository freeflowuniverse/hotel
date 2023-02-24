module tests

import freeflowuniverse.hotel.kitchen
import freeflowuniverse.hotel.bar

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.baobab.actor
import freeflowuniverse.baobab.actionrunner
import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.processor
import freeflowuniverse.crystallib.params

import time
import json

fn testsuite_begin() ! {

	// create baobab, actionrunner and processor
	mut b := client.new()!
	mut kitchenactor := kitchen.new()!
	mut baractor := bar.new()!
	mut ar := actionrunner.new(b, [&actor.IActor(kitchenactor),&actor.IActor(baractor)])
	mut processor_ := processor.Processor{}
	processor_.reset()!

	// concurrently run actionrunner, processor, and external client
	spawn (&ar).run()
	spawn (&processor_).run()
}

fn test_kitchen_actor () {
	kitchen_order := dummy_kitchen_order()
	vendor_actor('kitchen', kitchen_order) or {panic('kitchen: $err')}
}

fn test_bar_actor () {
	bar_order := dummy_bar_order()
	vendor_actor('bar', bar_order) or {panic('bar: $err')}
}

fn vendor_actor (actor_name string, order_init common.Order) ! {
	mut b := client.new() or { panic(err) }
	assert order_test(mut b, order_init, actor_name)! == true

	mut sent_orders := send_orders_test(mut b, false, actor_name)!
	assert sent_orders.filter(it.order_status == .open).len == 1
	assert sent_orders[0].for_id == order_init.for_id

	assert cancel_order_test(mut b, sent_orders[0], actor_name)! == true
	sent_orders = send_orders_test(mut b, false, actor_name)!
	assert sent_orders.filter(it.order_status == .cancelled).len == 1

	assert order_test(mut b, order_init, actor_name)! == true
	sent_orders = send_orders_test(mut b, true, actor_name)!
	assert sent_orders.len == 1

	assert close_order_test(mut b, sent_orders[0].id, actor_name)! == true
	sent_orders = send_orders_test(mut b, false, actor_name)!
	assert sent_orders.filter(it.order_status == .closed).len == 1

	d_product := dummy_product()
	product_id := add_product_test(mut b, d_product, actor_name) !
	assert product_id == '${actor_name[0].ascii_str().to_upper()}1'

	request := product.CatalogueRequest{}
	catalogue := send_catalogue_test(mut b, request, true, actor_name)!
	assert catalogue.products.len == 1
	assert catalogue.products[0].name == 'Sample Product'
}

// Input: order Order
// Output: 
// Internal: adds OpenJudgement to vendor.open_judgements
// Other: new job get_handles_from_ids - emmployee_ids []string, channel_type string - expects a list of handles
// Other: new jobs judge_cancellation - emmployee_id string, channel_type string, order Order
fn cancel_order_test(mut b client.Client, order common.Order, actor_name string) !bool {
	mut job := create_job([['order', json.encode(order)]], '${actor_name}.cancel_order') or {return error("Failed to create job: $err")}
	// todo check get_handles job and mock employeeactor response
	// todo check judge_cancellation job and mock employeeactor response
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	if response.state == .done {
		return true
	} else {
		return false
	}
}

// Input: order Order
// Output: 
// Internal: adds order to vendor.orders
// Other: new job get_handles_from_ids - emmployee_ids []string, channel_type string - expects a list of handles
// Other: new jobs announce_order - emmployee_id string, channel_type string, order Order
fn order_test(mut b client.Client, order common.Order, actor_name string) !bool {
	mut job := create_job([['order', json.encode(order)]], '${actor_name}.order') or {return error("Failed to create job: $err")}
	// todo check get_handles job and mock employeeactor response
	// todo check announce_order job
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	if response.state == .done {
		return true
	} else {
		return false
	}
}

// Input: order_id string
// Output: 
// Internal: updates order_status to closed
fn close_order_test(mut b client.Client, order_id string, actor_name string) !bool {
	mut job := create_job([['order_id', order_id]], '${actor_name}.close_order') or {return error("Failed to create job: $err")}
	// todo check order_status has switched to closed
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	if response.state == .done {
		return true
	} else {
		return false
	}
}

// Input: open bool
// Output: orders []Order
fn send_orders_test(mut b client.Client, open bool, actor_name string) ![]common.Order {
	mut job := create_job([['open', open.str()]], '${actor_name}.send_orders') or {return error("Failed to create job: $err")}
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	return json.decode([]common.Order, response.result.get('orders')!)!
}

// Input: everything bool, catalogue_request CatalogueRequest
// Output: catalogue, CatalogueRequest
fn send_catalogue_test(mut b client.Client, request product.CatalogueRequest, everything bool, actor_name string) !product.CatalogueRequest {
	mut job := create_job([['everything', everything.str()], ['catalogue_request', json.encode(request)]], '${actor_name}.send_catalogue') or {return error("Failed to create job: $err")}
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	return json.decode(product.CatalogueRequest, response.result.get('catalogue')!)!
}

// Input: product Product
// Output: product_id string
// Internal: adds product to internal state
// Other: returns a Product + id
fn add_product_test(mut b client.Client, product_ product.Product, actor_name string) !string {
	mut job := create_job([['product', json.encode(product_)]], '${actor_name}.add_product') or {return error("Failed to create job: $err")}
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	return response.result.get('product_id')!
}

// todo
fn confirm_order_cancellation_test(mut b client.Client) ! {}


fn create_job (pairs [][]string, actor_function string) !ActionJob {
	mut j_args := params.Params{}
	for pair in pairs {
		j_args.kwarg_add(pair[0], pair[1])
	}
	return jobs.new(
		action: 'hotel.$actor_function'
		args: j_args
	)!
}

fn dummy_product () product.Product {
	product_ := product.Product{
		name: 'Sample Product'
		description: 'a sample product description'
		price: finance.Price{
			val: 10
			currency: finance.Currency{
				name: 'USD'
				usdval: 1
			}
		}
		unit: .units
		variable_price: true
	}
	return product_
}

fn dummy_kitchen_order () common.Order {
	order := common.Order{
		for_id: 'BBBB'
		orderer_id: 'BBBB'
		start: time.now()
		product_amounts: [product.ProductAmount{
			quantity: '2'
			product: product.Product{
				id: 'K12'
				name: 'Chicken Curry'
				description: 'A delicious chicken curry served with vegetables'
				state: .ok
				price: finance.Price{
					val: 10
					currency: finance.Currency{
						name: 'USD'
						usdval: 1
					}
				}
				unit: .units
				variable_price: true
			}
		}]
		note: 'note'
		// additional_attributes: [common.Attribute{
		// 	key: 'room_service'
		// 	value: 'true'
		// 	value_type: 'bool'
		// }]
		order_status: .open
		target_actor: 'kitchen'
	}
	return order
}

fn dummy_bar_order () common.Order {
	order := common.Order{
		for_id: 'AAAA'
		orderer_id: 'AAAA'
		start: time.now()
		product_amounts: [product.ProductAmount{
			quantity: '2'
			product: product.Product{
				id: 'B01'
				name: 'diet coke'
				description: 'A diet coke'
				state: .ok
				price: finance.Price{
					val: 3
					currency: finance.Currency{
						name: 'USD'
						usdval: 1
					}
				}
				unit: .units
				variable_price: true
			}
		}]
		note: 'note'
		// additional_attributes: [common.Attribute{
		// 	key: 'room_service'
		// 	value: 'true'
		// 	value_type: 'bool'
		// }]
		order_status: .open
		target_actor: 'bar'
	}
	return order
}