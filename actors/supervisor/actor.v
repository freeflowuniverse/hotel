

module supervisor

import freeflowuniverse.hotel.actors.supervisor.supervisor_model
import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.baobab.client as baobab_client
import json
import freeflowuniverse.hotel.actors.kitchen.kitchen_model
import freeflowuniverse.hotel.actors.user.user_model


pub struct SupervisorActor {
pub mut:
	id         string
	supervisor ISupervisor
	baobab     baobab_client.Client
}

pub fn new() !SupervisorActor {
	supervisor := supervisor_model.Supervisor{}

	for actor in ['kitchen', 'user'] {
		supervisor.address_books << supervisor_model.AddressBook{actor_name: actor}
	}

	mut supervisor_actor := SupervisorActor{
		id: '0'
		supervisor: supervisor
		baobab: baobab_client.new()
	}

	return supervisor_actor
}

fn (actor SupervisorActor) run() {

}

fn (actor SupervisorActor) execute(mut job ActionJob) ! {
	match actionname {
		'create_kitchen' {
			if kitchen_instance := json.decode(kitchen_model.Kitchen_model.Kitchen, job.args.get('kitchen_instance')!) {
				actor.supervisor.create_kitchen(kitchen_instance)!
			}
		}
		'create_user' {
			if user_instance := json.decode(user_model.User_model.Guest, job.args.get('user_instance')!) {
				actor.supervisor.create_user(user_instance)!
			}
			if user_instance := json.decode(user_model.User_model.Employee, job.args.get('user_instance')!) {
				actor.supervisor.create_user(user_instance)!
			}
		}
		'get_address' {
			actor_name := job.args.get('actor_name')!
			actor_id := job.args.get('actor_id')!
			address := actor.supervisor.get_address(actor_name, actor_id)!
			job.result.kwarg_add('address', address)
		}
		'get_address_book' {
			actor_name := job.args.get('actor_name')!
			address_book := actor.supervisor.get_address_book(actor_name)!
			job.result.kwarg_add('address_book', json.encode(address_book))
		}
		'edit_address_book' {
			actor_name := job.args.get('actor_name')!
			address_book := json.decode(map[string]string, job.args.get('address_book')!)!
			actor.supervisor.edit_address_book(actor_name, address_book)!
		}
		'get' {
			encoded_supervisor := actor.supervisor.get()!
			job.result.kwarg_add('encoded_supervisor', encoded_supervisor)
		}
		else {
			job.state = .error
		}
	}
}