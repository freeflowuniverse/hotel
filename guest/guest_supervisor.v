module guest

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.client_builder

import json

const this_dir = os.dir(@FILE)

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

pub fn new_gs () !GuestSupervisor {
	// Automatically builds the client for the Guest Supervisor and Actors
	mut b := client_builder.new()
	b.read_spv_file(this_dir + '/guestactor.v')!
	b.write_file('guest_client/guest_client.v')!

	return GuestSupervisor{
		baobab: client.new()!
	}
}

fn (gs GuestSupervisor) handle_job (mut job ActionJob) ! {
	// todo some form of routing based on actionname
	// if the job is to initialize a flow
	mut guest := gs.identify_guest(job.args.get('user_id')!, job.args.get('channel_type')!)
	actionname := job.action.split('.').last()

	match actionname {
		'add_guest' {
			code := gs.add_guest(get_person(job)!)!
			job.result.kwarg_add('guest_code', code)
		}
		'actor_method' {
			// get params from job
			// parse params into function which executes synchronously
			// put results back into job
		}
		'order_product_flow' {
			// todo should this take in the job or should it take in params?
			// ! I think it necessarily must take in the job, otherwise it will be problematic. Let's consider the impacts tho of putting a mutable job into a new thread
			spawn guest.order_product_flow(job.args.get('chat_id')!, job.args.get('user_id')!, job.args.get('channel_type')!)!
		}
		'flow_method' {
			
		}
	}
}

fn (mut gs GuestSupervisor) add_guest (guest_person person.Person) !string {
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

	return guest.code
}

fn (gs GuestSupervisor) identify_guest (user_id string, channel_type string) !Guest {
	for guest in gs.guests {
		guest_user_id := match channel_type {
			'telegram' {guest.telegram}
			else {''}
		}
		if guest_user_id == user_id {
			return guest
		}
	}
	return error("Guest not found!")
}

fn (gs GuestSupervisor) generate_guest_code () string {
	mut guest_codes := []string{}
	for guest in gs.guests {
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
	return json.decode(person.Person, job.args.get('person')!)!
}