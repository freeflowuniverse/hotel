module guestactor

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.crystallib.gittools { GitStructure }
import freeflowuniverse.crystallib.sshagent
import freeflowuniverse.crystallib.ui

// todo figure out waiting

pub struct GuestActor {
	name string = 'hotel.guest'
	flows []Flow
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
		'order_product' {
			actor.order_product_flow(mut job)!
		}
		'view_outstanding' {
			actor.outstanding_flow(mut job)!
		}
		'get_code' {
			actor.get_code_flow(mut job)!
		}
		'help' {
			actor.help_flow(mut job)!
		}
		else {
			error('could not find guest action for job:\n${job}')
			return
		}
	}
}

// SUPERVISOR FUNCTIONS

// todo
pub fn (actor GuestActor) add_new_guest ()

// TO OTHER ACTORS

// get info
fn (actor GuestActor) get_product_catalogues (requests map[string]common.CatalogueRequest) !map[string]common.CatalogueRequest {
	// todo match the key (actor_char) with the appropriate actor
	// todo for each request create a job with the catalogue_request 
	// todo wait for responses 
}

// todo need to create an expose_info_response but one for each possible response

// order product
// should receive a Transaction message in return
fn (actor GuestActor) order (order common.Order) ! {
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
			'R' {'restaurant'}
			else {'other'}
		}
		// todo create job for order
		// todo send orders to appropriate actors
		actor.guests[order.orderer_id].orders[order.id] = order
	}	
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

// TODO QUESTION: some functions need to wait for an immediate response ie getting a catalogue to display to the user, while others ie submitting an order, dont need to wait for a response. In which cases should functions wait for a response as opposed to sending off the job and allowing it to come in naturally?