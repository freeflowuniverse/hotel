module vendor

import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.product
import freeflowuniverse.crystallib.params
import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.jobs {ActionJob}

import json

pub struct VendorMixin {
pub mut:
	name string
	open_judgements []OpenJudgement
	orders []common.Order
	employee_ids []string
	baobab client.Client
}

// todo move orders into VendorMixin (maybe change to an interface)

pub struct OpenJudgement {
pub mut:
	order_id string
	flow_guids []string
	source_guid string
}

pub fn (mut vendor VendorMixin) execute_vendor(mut job ActionJob) ! {
	actionname := job.action.split('.').last()

	match actionname {
		'cancel_order' {
			vendor.cancel_order(mut job)!
		}
		'order' {
			vendor.order(mut job)!
		}
		'close_order' {
			vendor.close_order(mut job)!
		}
		'send_orders' {
			vendor.send_orders(mut job)!
		}
		else {
			error('could not find vendor action for job:\n${job}')
			return
		}
	}
}

pub fn (vendor VendorMixin) send_catalogue (mut job ActionJob, products []product.Product) ! {
	request := json.decode(product.CatalogueRequest, job.args.get('catalogue_request')!)!
	everything := job.args.get('everything')!.bool()

	mut catalogue := product.CatalogueRequest{}
	if everything {
		for product in products {
			catalogue.products << product.ProductAvailability{
				Product: product
			}
		}
	} else {
		for pa in request.products {
			if products.filter(it.id==pa.id).len != 1 {
				break
			}
			catalogue.products << product.ProductAvailability{
				Product: products.filter(it.id==pa.id)[0]
			}
		}
	}

	job.result.kwarg_add('catalogue', json.encode(catalogue))
}

pub fn (vendor VendorMixin) add_product (mut job ActionJob, product_id string) !product.Product { 
	mut product_ := json.decode(product.Product, job.args.get('product')!)!
	product_.id = product_id
	// todo decide whether a product.constituent_products should hold products or product ids
	full_id := '${vendor.name[0].ascii_str().to_upper()}${product_id}'
	job.result.kwarg_add('product_id', full_id)
	return product_
}

pub fn (vendor VendorMixin) send_orders (mut job ActionJob) ! {

	mut orders := vendor.orders.clone()

	open := job.args.get('open')!.bool()
	if open {
		orders = orders.filter(it.order_status == .open)
	}

	job.result.kwarg_add('orders', json.encode(orders))
	}

pub fn (mut vendor VendorMixin) order (mut job ActionJob) ! {
	order := json.decode(common.Order, job.args.get('order')!)!

	vendor.orders << order

	channel_type := 'telegram'

	mut j_ids_args := params.Params{}
	j_ids_args.kwarg_add('employee_ids', json.encode(vendor.employee_ids))
	j_ids_args.kwarg_add('channel_type', channel_type)

	mut ids_job := vendor.baobab.job_new(
		args: j_ids_args
		action: 'hotel.employee.get_handles_from_ids'
	)!
	response := vendor.baobab.job_schedule_wait(mut ids_job, 0)!
	handles := json.decode([]string, response.result.get('handles')!)!

	mut j_flow_args := params.Params{}
	j_flow_args.kwarg_add('order', job.args.get('order')!)
	j_flow_args.kwarg_add('channel_type', channel_type)

	for user_id in handles {
		j_flow_args.kwarg_add('user_id', user_id)
		mut flow_job := vendor.baobab.job_new(
			args: j_flow_args
			action: 'hotel.flowsactor.announce_order'
		)!
		vendor.baobab.job_schedule(mut flow_job)!
	}
}

// returns job guid
pub fn (mut vendor VendorMixin) cancel_order (mut job ActionJob) ! {

	channel_type := 'telegram'

	mut j_ids_args := params.Params{}
	j_ids_args.kwarg_add('employee_ids', json.encode(vendor.employee_ids))
	j_ids_args.kwarg_add('channel_type', channel_type)

	mut ids_job := vendor.baobab.job_new(
		args: j_ids_args
		action: 'hotel.employee.get_handles_from_ids'
	)!
	response := vendor.baobab.job_schedule_wait(mut ids_job, 0)!
	handles := json.decode([]string, response.result.get('handles')!)!

	mut n_job_guids := []string{}

	mut j_args := params.Params{}
	j_args.kwarg_add('order', job.args.get('order')!)
	j_args.kwarg_add('channel_type', 'telegram')

	for user_id in handles {
		j_args.kwarg_add('user_id', user_id)
		mut n_job := vendor.baobab.job_new(
			action: 'hotel.flowsactor.judge_cancellation'
			args: j_args
		)!
		vendor.baobab.job_schedule(mut n_job)!
		n_job_guids << n_job.guid
	}

	vendor.open_judgements << OpenJudgement{
		order_id: json.decode(common.Order, job.args.get('order')!)!.id
		flow_guids: n_job_guids
		source_guid: job.guid
	}
}

pub fn (mut vendor VendorMixin) close_order (mut job ActionJob) ! {
	order_id := job.args.get('order_id')!
	mut orders := vendor.orders.filter(it.id==order_id)
	if orders.len == 0 {
		return error("Order id not found")
	}
	vendor.orders = vendor.orders.filter(it.id!=order_id).clone()
	orders[0].order_status = .closed
	vendor.orders << orders[0]
}

pub fn (mut vendor VendorMixin) confirm_order_cancellation (mut job ActionJob, open_judgement OpenJudgement) ! {
	order_id := job.args.get('order_id')!
	order := vendor.orders.filter(it.id==order_id)

	mut log_j_args := params.Params{}
	log_j_args.kwarg_add('order', json.encode(order))
	mut log_job := vendor.baobab.job_new(
		action: 'hotel.guest.log_order_cancellation'
		args: log_j_args
	)!
	vendor.baobab.job_schedule(mut log_job)!

	// sends a message to the original flow that tried to cancel an order
	mut flow_j_args := params.Params{}
	flow_j_args.kwarg_add('order', json.encode(order))
	flow_j_args.kwarg_add('vendor_name', vendor.name)
	mut flow_job := vendor.baobab.job_new(
		action: 'hotel.flowsactor'
		args: flow_j_args
	)!

	flow_job.guid = open_judgement.source_guid
	// todo delete old job from jobs.db
	// todo put this job into jobs.db and the guid into the result queue
	// vendor.baobab.job_schedule(mut flow_job)!
	// // add job to processor.result queue
	// mut q_result := vendor.client.redis.queue_get('jobs.processor.result')
	// q_result.add(flow_job.guid)!
}

pub fn generate_product_id (products []product.Product) !string {
	mut greatest_id := 1
	for product in products {
		if product.id.int() > greatest_id {
			greatest_id = product.id.int()
		}
	}
	return (greatest_id + 1).str()
}

