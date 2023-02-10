module guest

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.person

import json

// todo figure out waiting

// todo figure out how to generate new ids that are unique

// todo order confirmations and cancel order confirmations

// todo remember to set job status to done if they were done succesfully

pub struct GuestActor {
	name string = 'hotel.guest'
	guests map[string]Guest // where string is guest code
}

pub fn (mut actor GuestActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active guest..')
		println(job)
	}
	// used to initialize gitstructure by default
	// if git init action isn't the first job

	actionname := job.action.split('.').last()

	match actionname {
		'validate_guest_code' {
			actor.validate_guest_code(mut job)
		}
		'get_guest_code' {
			actor.get_guest_code(mut job)
		}
		'get_guest_code_from_telegram' {
			actor.get_guest_code_from_telegram(mut job)
		}
		'add_guest' {
			actor.add_guest(mut job)
		}
		// todo 
		'receive_funds' {
			actor.receive_funds(mut job)
		}
		'order' { // todo 
			actor.order(mut job)
		}
		// 'confirm_cancelled_order'
		else {
			error('could not find guest action for job:\n${job}')
			return
		}
	}
}

// SUPERVISOR FUNCTIONS

// todo
pub fn (actor GuestActor) add_guest (job ActionJob) ! {
	guest := json.decode(job.args.get('guest')) as Guest

	// todo validate that this guest doesnt exist already
	for code, guest_ in actor.guests {
		if guest_.email == guest.email {
			job.state = .error
			actor.baobab.job_schedule(job)!
			return
		}
	}

	guest.code = generate_guest_code()
	actor.guests[guest.code] = guest

	job.result.add_kwarg('guest_code', guest.code)
	
	actor.baobab.job_schedule(job)!
}

// TO OTHER ACTORS

// get info
fn (actor GuestActor) get_product_catalogues (requests map[string]common.CatalogueRequest) !map[string]common.CatalogueRequest {
	mut job_guids := []string{}
	for key, request in requests {
		target_actor := match key {
			'R' {'restaurant'}
			else {'error'} // todo how to handle this
		}
		j_args := params.Params{}
		j_args.kwarg_add('catalogue', json.encode(request))

		job := actor.baobab.job_new(
			action: 'hotel.${target_actor}.catalogue_request' //todo
			args: j_args
		)!

		actor.baobab.schedule_job(job, 0)!

		job_guids << job.guid
	}
	// todo how to make sure this is efficiently returned
	// todo also how to do error handling
	mut catalogues := map[string]common.CatalogueRequest{}
	for guid in job_guids {
		job := actor.baobab.job_wait(5)
		catalogues[job.src_action] = job.args.get('catalogue')
	}

	return catalogues
}

// todo need to create an expose_info_response but one for each possible response

// order product
// should receive a Transaction message in return
fn (actor GuestActor) order (mut job ActionJob) ! {
	order := json.decode(common.Order, job.args.get('order'))
	// todo check enough in balance
	orders := map[string]common.Order{}
	for p_amount in order.product_amounts {
		actor_char := p_amount.product.id[0].ascii_str()
		if actor_char !in orders.keys {
			orders[actor_char] = Order{
				id: actor.generate_order_id()
			}
		}
		orders[actor_char].product_amounts << p_amount
	}
	
	job_guids := []string
	
	for actor_char, order in orders {
		order.target_actor = match actor_char {
			'K' {'kitchen'}
			'B' {'bar'}
			else {'other'}
		}
		j_args := params.Params{}
		j_args.kwarg_add('order', json.encode(order))
		n_job := actor.baobab.job_new(
			action: 'hotel.${order.target_actor}.order'
			args: j_args
		)!
		actor.baobab.schedule_job(n_job, 0)!
		job_guids << n_job.guid
	}	

	success_orders := []common.Order{}
	failure_orders := []common.Order{}

	for guid in job_guids {
		response := actor.job_wait(guid, 10)!
		if response.state == .done {
			success_orders << response.args.get('order')
		} else {
			failure_orders << response.args.get('order') // todo maybe we wont get this response so instead we should just display successful orders
		}
	}

	job.result.kwarg_add('success_orders', success_orders)
	job.result.kwarg_add('failure_orders', failure_orders)
	job.state = .done
	actor.baobab.job_schedule(job)

	for order in success_orders {
		actor.guests[order.for_id].orders[order.id] = order
	}
}

fn (actor GuestActor) cancel_order (mut job ActionJob) ! {
	order := json.decode(common.Order, job.args.get('order'))

	actor.guests[order.for_id].orders[order.id].status = .cancel	

	action := 'hotel.${order.target_actor}.cancel_order'

	if common.cancel_order(order, action, actor.baobab) {
		job.state = .done
	} else {
		job.state = .error
	}
	actor.baobab.schedule(job)!
	// todo pass this guid to guest actor to wait for a response
}

// UTILITY FUNCTIONS

fn (actor GuestActor) get_guest_code_from_telegram (job ActionJob) {
	mut found := false 
	telegram_username := job.args.get('telegram_username')
	for guest in actor.guests {
		if guest.telegram_username == telegram_username {
			job.result.kwarg_add('guest_code', guest.code)
			found = true
		}
	}
	if found == false {
		job.state = .error
	}
	actor.baobab.job_schedule(job)!
}

//! Deprecated I think
// todo maybe turn this into get_products?
fn (actor GuestActor) get_product (requests map[string]common.CatalogueRequest) !Product {
	catalogues := actor.get_product_catalogues(requests)!

	product_availability := catalogues[catalogues.keys()[0]]
	if product_availability.available == true {
		return product_availability.Product
	} else {
		return error("Product ${catalogues.keys()[0]}${product_availability.id} unavailable")
	}
}


fn (actor GuestActor) generate_guest_code () string {
	mut guest_codes := []string{}
	for guest in actor.guests {
		guest_codes << guest.code
	}
	mut valid := false
	mut code := ''
	for valid == false {
		code = rand.string(4).to_upper()
		if code !in guest_codes {
			valid = true
		}
	}
	return code
}

fn (actor GuestActor) generate_order_id () string {
	mut maximum_id := 0
	for guest in actor.guests {
		for id, _ in guest.orders {
			if id.int() > maximum_id {
				maximum_id = id.int()
			}
		}
	}
	return maximum_id.str()
}


// TODO QUESTION: some functions need to wait for an immediate response ie getting a catalogue to display to the user, while others ie submitting an order, dont need to wait for a response. In which cases should functions wait for a response as opposed to sending off the job and allowing it to come in naturally?

// FROM OTHER ACTORS

fn (actor GuestActor) validate_guest_code (mut job ActionJob) {
	guest_code := job.args.get('guest_code')
	mut valid := false
	for guest in actor.guests {
		if guest.code == guest_code {
			valid = true
		}
	}
	job.result.kwarg_add('guest_code', '$valid')
	// todo send job back to employee
}

fn (actor GuestActor) get_guest_code (mut job ActionJob) ! {
	firstname := job.args.get('firstname')
	lastname := job.args.get('lastname')
	email := job.args.get('email')
	for guest in actor.guests {
		if guest.firstname == firstname && guest.lastname == lastname && guest.email == email {
			job.result.kwarg_add('guest_code', '$guest.code')
		}
	}
	// todo send job back to employee
}

fn (actor GuestActor) receive_funds (mut job ActionJob) ! {
	transaction := job.args.get('transaction')

	actor.guests[transaction.sender]
	// todo send job back to employee

	//! THIS IS WHERE I AM SO FAR

	// todo I need to resolve the sender, receiver issue ie if a guest adds money to their digital funds are they the sender or receiver?
}