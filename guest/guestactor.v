module guest

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.hotel.library.person
import freeflowuniverse.baobab.client

import json
import rand
import os



// todo figure out waiting

// todo figure out how to generate new ids that are unique

// todo order confirmations and cancel order confirmations

// todo remember to set job status to done if they were done succesfully

pub struct GuestActor {
pub mut:
	name string = 'hotel.guest'
	guests []Guest 
	baobab client.Client
}

pub fn new() !GuestActor {
	return GuestActor{
		baobab: client.new()!
	}
}

pub fn (mut actor GuestActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active guest..')
		println("Execute Input:")
		println(job)
	}
	// used to initialize gitstructure by default
	// if git init action isn't the first job

	actionname := job.action.split('.').last()

	match actionname {
		'validate_guest_code' {
			actor.validate_guest_code(mut job)!
		}
		'send_guest_code_from_details' {
			actor.send_guest_code_from_details(mut job)!
		} 
		'send_guest_person' {
			actor.send_guest_person(mut job)!
		}
		'log_order' {
			actor.log_order(mut job)!
		}
		'log_order_cancellation' {
			actor.log_order_cancellation(mut job)!
		}
		'send_guest_code_from_handle' {
			actor.send_guest_code_from_handle(mut job)!
		}
		'send_guest_orders' {
			actor.send_guest_orders(mut job)!
		}
		'add_guest' {
			actor.add_guest(mut job)!
		}
		// TODO 'receive_funds' {
		// 	actor.receive_funds(mut job)
		// }
		else {
			error('could not find guest action for job:\n${job}')
			return
		}
	}

	$if debug {
		println("Execute Output:")
		println(job)
	}
}

pub fn (mut actor GuestActor) add_guest (mut job ActionJob) ! {
	mut guest := Guest{
		Person: json.decode(person.Person, job.args.get('guest_person')!)!
	}

	for _, guest_ in actor.guests {
		if guest_.email == guest.email {
			job.state = .error
			return error("Guest already exists")
		}
	}

	guest.code = actor.generate_guest_code()
	actor.guests << guest

	job.result.kwarg_add('guest_code', guest.code)
}

fn (mut actor GuestActor) log_order (mut job ActionJob) ! {
	mut order := json.decode(common.Order, job.args.get('order')!)!

	if actor.guests.filter(it.code == order.for_id).len == 0 {
		return error("Guest could not be found")
	}

	mut total_price := finance.Price{
		val: 0
		currency: order.product_amounts[0].product.price.currency
	}
	for mut p_a in order.product_amounts {
		total_price.add(p_a.product.price.multiply(p_a.quantity.int()))!
	} 

	mut guest := actor.guests.filter(it.code==order.for_id)[0]
	actor.guests = actor.guests.filter(it.code!=guest.code).clone() // todo is clone necessary?
	guest.orders << order
	guest.digital_funds.deduct(total_price)!
	actor.guests << guest
}

fn (mut actor GuestActor) log_order_cancellation (mut job ActionJob) ! {
	mut order := json.decode(common.Order, job.args.get('order')!)!
	vendor_name := job.args.get('vendor_name')!

	actor.guests.filter(it.code==order.for_id)[0].orders.filter(it.target_actor==vendor_name).filter(it.id==order.id)[0].order_status = .cancelled

	mut total_price := finance.Price{
		val: 0
		currency: order.product_amounts[0].product.price.currency
	}
	for mut p_a in order.product_amounts {
		total_price.add(p_a.product.price.multiply(p_a.quantity.int()))!
	} 
	
	mut balance := actor.guests.filter(it.code==order.for_id)[0].digital_funds
	balance.add(total_price)!
	actor.guests.filter(it.code==order.for_id)[0].digital_funds = balance
}


fn (mut actor GuestActor) send_guest_code_from_handle (mut job ActionJob) ! {
	mut found := false 
	channel_type := job.args.get('channel_type')!
	user_id := job.args.get('user_id')!
	for guest in actor.guests {
		target_user_id := match channel_type {
			'telegram' {guest.telegram_username}
			else {''}
		}
		if user_id == target_user_id {
			job.result.kwarg_add('guest_code', guest.code)
			found = true
		}
	}
	if found == false {
		return error("Failed to get guest code from handle")
	}
}


fn (mut actor GuestActor) validate_guest_code (mut job ActionJob) ! {
	guest_code := job.args.get('guest_code')!.to_upper()
	mut valid := false
	for guest in actor.guests {
		if guest.code == guest_code {
			valid = true
		}
	}
	if valid == true {
		job.result.kwarg_add('guest_code', '$valid')
	} else {
		return error("Failed to find guest")
	}
}

fn (mut actor GuestActor) send_guest_code_from_details (mut job ActionJob) ! {
	firstname := job.args.get('firstname')!
	lastname := job.args.get('lastname')!
	email := job.args.get('email')!
	mut valid := false
	for guest in actor.guests {
		if guest.firstname == firstname && guest.lastname == lastname && guest.email == email {
			job.result.kwarg_add('guest_code', '$guest.code')
			valid = true
		}
	}
	if valid != true {
		return error("Failed to get guest code fromd detials")
	}
}

fn (mut actor GuestActor) send_guest_person (mut job ActionJob) ! {
	guest_code := job.args.get('guest_code')!
	guest_list := actor.guests.filter(it.code==guest_code)
	if guest_list.len != 1 {
		return error("Could not find guest_code")
	}
	job.result.kwarg_add('guest_person', json.encode(guest_list[0].Person))
}

fn (mut actor GuestActor) send_guest_orders (mut job ActionJob) ! {
	guest_code := job.args.get('guest_code')!
	// make sure that this gets a guest_code
	guest_list := actor.guests.filter(it.code==guest_code)
	if guest_list.len != 1 {
		return error("Could not find guest_code")
	}
	active := job.args.get('active')!.bool()
	mut orders := guest_list[0].orders.clone()
	if active {
		orders = orders.filter(it.order_status==.open)
	}
	job.result.kwarg_add('orders', json.encode(orders))
}