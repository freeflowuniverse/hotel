module guest

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.guest.actor
import json

/*
Components:
- UI Handlers 
- Supervisor Actors
  - CRUD data
  - spawn regular actors
- Regular Actors
  - Flows
    - use the ui lib to communicate with 
*/

struct GuestSupervisor {
	name string = 'hotel.guest_supervisor'
	baobab client.Client
	guests []Guest
}

fn (gs GuestSupervisor) handle_job (mut job ActionJob) ! {
	// todo some form of routing based on actionname
	// if the job is to initialize a flow
	mut guest := gs.identify_guest(job.args.get('user_id')!, job.args.get('channel_type')!)
	actionname := job.action.split('.').last()

	match actionname {
		'add_guest' {
			code, name := gs.add_guest(get_person(job)!)!
			job.result.kwarg_add('code', code)
			job.result.kwarg_add('name', name)
		}
		'identify_guest' {
			guest_person, guest_code := gs.identify_guest('a', 'b')!
			job.result.kwarg_add('guest_person', guest_person)
			job.result.kwarg_add('guest_code', guest_code)
		}
		'order_product_flow' {
			// todo should this take in the job or should it take in params?
			// ! I think it necessarily must take in the job, otherwise it will be problematic. Let's consider the impacts tho of putting a mutable job into a new thread
			spawn guest.order_product_flow(job.args.get('chat_id')!, job.args.get('user_id')!, job.args.get('channel_type')!)!
		}
	}
}

fn (mut gs GuestSupervisor) add_guest (guest_person person.Person) !(string, string) {
	mut guest := Guest{
		Person: guest_person
		baobab: &gs.baobab
	}

	for _, guest_ in actor.guests {
		if guest_.email == guest.email {
			return error("Guest already exists")
		}
	}

	guest.code = gs.generate_guest_code()
	actor.guests << guest

	return guest.code, guest.name
}

fn (gs GuestSupervisor) identify_guest (user_id string, channel_type string) !(person.Person, string) {
	for guest in gs.guests {
		guest_user_id := match channel_type {
			'telegram' {guest.telegram}
			else {''}
		}
		if guest_user_id == user_id {
			return guest.Person, guest.code
		}
	}
	return error("Guest not found!")
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

fn get_person(job ActionJob) !person.Person {
	return := json.decode(person.Person, job.args.get('person')!)!
}