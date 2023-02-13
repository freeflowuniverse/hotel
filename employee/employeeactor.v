module guest

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.product


import json

// todo figure out waiting

// todo figure out error messages both in internal functions and errors from other actors

// todo consider putting guest_orders into EmployeeActor not Employee

pub struct EmployeeActor {
	name string = 'hotel.employee'
	employees map[string]Employee // where string is guest code
}

pub fn (mut actor EmployeeActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active employee..')
		println(job)
	}

	actionname := job.action.split('.').last()

	match actionname {
		'guest_order' {
			actor.guest_order(mut job)
		}
		'get_employee_from_telegram' {
			actor.get_employee_from_telegram(mut job)
		} 
		'cancel_guest_order' {
			actor.cancel_guest_order(mut job)
		}
		else {
			error('could not find employee action for job:\n${job}')
			return
		}
	}
}

// SUPERVISOR FUNCTIONS

// todo
pub fn (actor EmployeeActor) add_new_employee ()

// TO OTHER ACTORS

// ! not needed yet
// // get info
// fn (actor EmployeeActor) get_product_catalogues (requests map[string]common.CatalogueRequest) !map[string]common.CatalogueRequest {
// 	for request 
// 	// todo match the key (actor_char) with the appropriate actor
// 	// todo for each request create a job with the catalogue_request 
// 	// todo wait for responses 
// }


// order product
// should receive a Transaction message in return
fn (actor EmployeeActor) guest_order (mut job ActionJob) ! {
	order := json.decode(common.Order, job.args.get('order'))
	// ? should the full order be logged or the constituent parts logged?

	success_orders, failure_orders := common.forward_order(order, 'hotel.guest.order', actor.baobab)!

	job.state = .done
	job.result.kwarg_add('success_orders', success_orders)
	job.result.kwarg_add('failure_orders', failure_orders)
	actor.baobab.job_schedule(job) // todo should this be wait?
	for order in success_orders {
		actor.employees[order.orderer_id].guest_orders[order.id] = order
	}
}

fn (actor EmployeeActor) cancel_guest_order (mut job ActionJob) ! {
	order := json.decode(common.Order, job.args.get('order'))

	for employee in actor.employees {
		if order.id in employee.guest_orders.keys() {
			employee.guest_orders[order.id].status = .cancel
		}
	}

	action := 'hotel.guest.cancel_order'

	if common.cancel_order(order, action, actor.baobab) {
		job.state = .done
	} else {
		job.state = .error
	}
	actor.baobab.schedule_job(job, 0)!
	// todo pass this guid to guest actor to wait for a response
}

fn (actor EmployeeActor) get_employee_from_telegram (job ActionJob) {
	telegram_username := job.args.get('telegram_username')

	mut found := false 
	for employee in actor.employees {
		if employee.telegram_username == telegram_username {
			job.result.kwarg_add('employee', employee.Person)
			found = true
		}
	}
	if found == false {
		job.state = .error
	}
	actor.baobab.job_schedule(job)!
}


// UTILITY FUNCTIONS

//! Deprecated I think
// todo maybe turn this into get_products?
fn (actor EmployeeActor) get_product (requests map[string]common.CatalogueRequest) !prdouct.Product {
	catalogues := actor.get_product_catalogues(requests)!

	product_availability := catalogues[catalogues.keys()[0]]
	if product_availability.available == true {
		return product_availability.Product
	} else {
		return error("Product ${catalogues.keys()[0]}${product_availability.id} unavailable")
	}
}

// TODO QUESTION: some functions need to wait for an immediate response ie getting a catalogue to display to the user, while others ie submitting an order, dont need to wait for a response. In which cases should functions wait for a response as opposed to sending off the job and allowing it to come in naturally?
