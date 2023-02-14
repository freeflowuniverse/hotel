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
	guests []Guest 
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
		'send_guest_code_from_details' {
			actor.send_guest_code_from_details(mut job)
		} 
		'send_guest_person' {
			actor.send_guest_person(mut job)
		}
		'log_order' {
			actor.log_order(mut job)
		}
		'log_order_cancellation' {
			actor.log_order_cancellation(mut job)
		}
		TODO 'send_guest_code_from_handle' {
			actor.send_guest_code_from_handle(mut job)
		}
		// TODO 'add_guest' {
		// 	actor.add_guest(mut job)
		// }
		// TODO 'send_guest_active_orders' {
		// 	actor.send_guest_active_orders(mut job)
		// }
		// TODO 'receive_funds' {
		// 	actor.receive_funds(mut job)
		// }
		else {
			error('could not find guest action for job:\n${job}')
			return
		}
	}
}

// SUPERVISOR FUNCTIONS

// ! NOT DONE YET // TODO 
// pub fn (actor GuestActor) add_guest (job ActionJob) ! {
// 	guest := json.decode(job.args.get('guest')) as Guest

// 	// todo validate that this guest doesnt exist already
// 	for code, guest_ in actor.guests {
// 		if guest_.email == guest.email {
// 			job.state = .error
// 			actor.baobab.job_schedule(job)!
// 			return
// 		}
// 	}

// 	guest.code = generate_guest_code()
// 	actor.guests[guest.code] = guest

// 	job.result.add_kwarg('guest_code', guest.code)
	
// 	actor.baobab.job_schedule(job)!
// }

fn (actor GuestActor) log_order (mut job ActionJob) {
	order := json.decode(common.Order, job.args.get('order')!)!

	actor.guests.filter(it.code==order.for_id)[0].orders << order

	mut total_price := Price{
		val: 0
		currency: order.product_amounts[0].currency
	}
	for p_a in order.product_amounts {
		total_price.add(p_a.product.price.multiply(p_a.quantity))!
	} 

	actor.guests.filter(it.code==order.for_id)[0].digital_funds.deduct(total_price)
}

fn (actor GuestActor) log_order_cancellation (mut job ActionJob) {
	order := json.decode(common.Order, job.args.get('order')!)!
	vendor_name := job.args.get('vendor_name')!

	actor.guests.filter(it.code==order.for_id)[0].orders.filter(it.target_actor==vendor_name&&it.id==order.id)[0].order_status = .cancelled

	mut total_price := Price{
		val: 0
		currency: order.product_amounts[0].currency
	}
	for p_a in order.product_amounts {
		total_price.add(p_a.product.price.multiply(p_a.quantity))!
	} 

	actor.guests.filter(it.code==order.for_id)[0].digital_funds.add(total_price)
}


fn (actor GuestActor) send_guest_code_from_handle (job ActionJob) {
	mut found := false 
	channel_type := job.args.get('channel_type')!
	telegram_username := job.args.get('user_id')!
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

fn (actor GuestActor) validate_guest_code (mut job ActionJob) {
	guest_code := job.args.get('guest_code')
	mut valid := false
	for guest in actor.guests {
		if guest.code == guest_code {
			valid = true
		}
	}
	if valid == true {
		job.result.kwarg_add('guest_code', '$valid')
		job.state = .done
	} else {
		job.state = .error
	}
	
	actor.baobab.job_schedule(job)!
}

fn (actor GuestActor) send_guest_code_from_details (mut job ActionJob) ! {
	firstname := job.args.get('firstname')!
	lastname := job.args.get('lastname')!
	email := job.args.get('email')!
	mut valid := false
	for guest in actor.guests {
		if guest.firstname == firstname && guest.lastname == lastname && guest.email == email {
			job.result.kwarg_add('guest_code', '$guest.code')
			job.state = .done
			valid = true
		}
	}
	if valid != true {
		job.state = .error
	}
	actor.baobab.job_schedule(job)!
}

fn (actor GuestActor) send_guest_person (mut job ActionJob) ! {
	guest_code := job.args.get('guest_code')!
	guest := actor.guests.filter(it.code==guest_code)[0]
	job.result.kwarg_add('guest_person', guest.Person)
	job.state = .done
	actor.baobab.job_schedule(job)!
}

fn (actor GuestActor) send_guest_active_orders (mut job ActionJob) ! {
	guest_code := job.args.get('guest_code')!
	active_orders := guest := actor.guests.filter(it.code==guest_code)[0].orders.filter(it.order_status==.open)
	job.result.kwarg_add('active_orders', active_orders)
	job.state = .done
	actor.baobab.job_schedule(job)!
}