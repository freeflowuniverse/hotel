module guest

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common

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
	// used to initialize gitstructure by default
	// if git init action isn't the first job

	actionname := job.action.split('.').last()

	// todo need to decide whether to decode job here or later
	// todo ie do we need to convert job into user_id and channel_type now or make a function to do it at the beginning of every flow

	match actionname {
		'order_guest_product' {
			actor.order_guest_product_flow(job)!
		}
		'view_guest_outstanding' {
			actor.guest_outstanding_flow(job)!
		}
		'get_guest_code' {
			actor.get_guest_code_flow(job)!
		}
		'help' {
			actor.help_flow(job)!
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

// get info
fn (actor EmployeeActor) get_product_catalogues (requests map[string]common.CatalogueRequest) !map[string]common.CatalogueRequest {
	for request 
	// todo match the key (actor_char) with the appropriate actor
	// todo for each request create a job with the catalogue_request 
	// todo wait for responses 
}

// todo need to create an expose_info_response but one for each possible response

// order product
// should receive a Transaction message in return
fn (actor EmployeeActor) guest_order (order common.Order) ! {
	orders := map[string]common.Order{}
	for p_amount in order.product_amounts {
		actor_char := p_amount.product.id[0].ascii_str()
		if actor_char !in orders.keys {
			orders[actor_char] = CatalogueRequest{}
		}
		orders[actor_char].product_amounts << p_amount
	}
	
	for actor_char, order in orders {
		order.target_actor = match actor_char {
			'R' {'restaurant'} //todo the rest of the character
			else {'other'}
		}
		// todo create job for order
		// todo send orders to appropriate actors
		actor.employees[order.orderer_id].guest_orders[order.id] = order
		// todo send order to guestactor so that they can log it
	}	
}

fn (actor EmployeeActor) cancel_guest_order (order common.Order) ! {
	for employee in actor.employees {
		if order.id in employee.guest_orders.keys() {
			employee.guest_orders[order.id].status = .cancel
		}
	}
	
	j_args := params.Params{}

	j_args.kwarg_add('order', json.encode(order))

	job := actor.baobab.job_new(
		action: 'hotel.guest.cancel_order' //todo
		args: j_args
	)!

	actor.baobab.schedule_job(job, 0)!
}



fn (actor EmployeeActor) get_guest_code (firstname string, lastname string, email string) !string {

	j_args := params.Params{}

	j_args.kwarg_add('firstname', firstname)
	j_args.kwarg_add('lastname', lastname)
	j_args.kwarg_add('email', email)

	job := actor.baobab.job_new(
		action: 'hotel.guest.get_guest_code' //todo
		args: j_args
	)!

	response := actor.baobab.schedule_job_wait(job, 0)!
	if response.args.exists('guest_code'){
		return response.args.get('guest_code')
	} else {
		return error("Guest does not exist")
	}
}

fn (actor EmployeeActor) validate_guest_code(guest_code string) !bool {

	j_args := params.Params{}

	j_args.kwarg_add('guest_code', guest_code)

	job := actor.baobab.job_new(
		action: 'hotel.guest.validate_guest_code' //todo
		args: j_args
	)!

	response := actor.baobab.schedule_job_wait(job, 0)!
	if response.args.get('guest_code') == 'true' {
		return true
	} else {
		return false
	}
}

fn (actor EmployeeActor) get_guest_balance (guest_code string) !Price {

	j_args := params.Params{}

	j_args.kwarg_add('guest_code', guest_code)

	job := actor.baobab.job_new(
		action: 'hotel.guest.get_guest_balance' //todo
		args: j_args
	)!

	response := actor.baobab.schedule_job_wait(job, 0)!

	if respone.args.get('found') == 'true'{
		return response.args.get('balance')
	} else {
		return error("Guest balance not found")
	}
	
}

// UTILITY FUNCTIONS

fn (actor EmployeeActor) get_employee_from_telegram (telegram_username string) Employee {
	for employee in actor.employees {
		if employee.telegram_username == telegram_username {
			return employee
		}
	}
	return Employee{}
}

// todo maybe turn this into get_products?
fn (actor EmployeeActor) get_product (requests map[string]common.CatalogueRequest) !Product {
	catalogues := actor.get_product_catalogues(requests)!

	product_availability := catalogues[catalogues.keys()[0]]
	if product_availability.available == true {
		return product_availability.Product
	} else {
		return error("Product ${catalogues.keys()[0]}${product_availability.id} unavailable")
	}
}

// TODO QUESTION: some functions need to wait for an immediate response ie getting a catalogue to display to the user, while others ie submitting an order, dont need to wait for a response. In which cases should functions wait for a response as opposed to sending off the job and allowing it to come in naturally?
