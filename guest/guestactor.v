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
		'order_product_flow' {
			actor.order_product_flow(job)!
		}
		'view_outstanding_flow' {
			actor.outstanding_flow(job)!
		}
		'get_code_flow' {
			actor.get_code_flow(job)!
		}
		'help_flow' {
			actor.help_flow(job)!
		}
		'validate_guest_code' {
			actor.validate_guest_code(mut job)
		}
		'get_guest_code' {
			actor.get_guest_code(mut job)
		}
		'add_guest' {
			actor.add_guest(mut job)
		}
		'receive_funds' {
			actor.receive_funds(mut job)
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
fn (actor GuestActor) order (order common.Order) ! {
	// todo check enough in balance
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
			'K' {'kitchen'} // todo change this everywhere
			else {'other'}
		}
		// todo create job for order
		// todo send orders to appropriate actors
		actor.guests[order.for_id].orders[order.id] = order
	}	
}

fn (actor GuestActor) cancel_order_internal (order common.Order) ! {
	actor.guests[order.for_id].orders[order.id].status = .cancel	
	// todo function to send this order to the appropriate actor
	j_args := params.Params{}

	j_args.kwarg_add('order', json.encode(order))

	job := actor.baobab.job_new(
		action: 'hotel.${order.target_actor}.cancel_order' //todo
		args: j_args
	)!

	actor.baobab.schedule_job(job, 0)!
}

// UTILITY FUNCTIONS

fn (actor GuestActor) get_guest_from_telegram (telegram_username string) Guest {
	for guest in actor.guests {
		if guest.telegram_username == telegram_username {
			return guest
		}
	}
	return Guest{}
}

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

fn (actor GuestActor) get_guest_balance (mut job ActionJob) {
	guest_code := job.args.get('guest_code')
	mut balance := finance.Price{}
	mut found := false 
	for guest in actor.guests {
		if guest.code == guest_code {
			balance = guest.digital_funds
			found = true
		}
	}
	job.result.kwarg_add('found', 'true')
	job.result.kwarg_add('balance', balance)
	
	// todo send job back to employee
}

fn (actor GuestActor) cancel_order (job ActionJob) {
	actor.cancel_order_internal(json.decode(job.args.get('order')))
}

fn (actor GuestActor) receive_funds (mut job ActionJob) ! {
	transaction := job.args.get('transaction')

	actor.guests[transaction.sender]
	// todo send job back to employee

	//! THIS IS WHERE I AM SO FAR

	// todo I need to resolve the sender, receiver issue ie if a guest adds money to their digital funds are they the sender or receiver?
}