module supervisor

import freeflowuniverse.hotel.library.models
import freeflowuniverse.baobab.client as baobab_client

// keeps a map of addresses of actors 
// creates new actors
// reinitialise / delete zombie actors

struct SupervisorActor {
	id string
	supervisor models.ISupervisor
	baobab baobab_client.Client
}

fn (mut a SupervisorActor) run () {
	// infinite loop
}

fn (mut actor SupervisorActor) execute (mut job ActionJob) ! {

	actionname := job.action.split('.').last()

	match actionname {
		'get_address' {
			actor_name := job.args.get('actor_name')!
			actor_id := job.args.get('actor_id')!
			address := actor.get_address(actor_name, actor_id)!
			job.result.kwarg_add('address', address) 
		}
		'get_address_book' {
			actor_name := job.args.get('actor_name')!
			address_book := actor.get_address_book(actor_name)!
			job.result.kwarg_add('address_book', json.encode(address_book)) 
		}
		'find_user' {
			identifier := job.params.get('identifier')!
			identifier_type := job.params.get('identifier_type')!
			user, user_type := actor.find_user(identifier, identifier_type)!
			job.result.kwarg_add('user', json.encode(models.IUser(user))) // ! Is this a valid casting here?
			job.result.kwarg_add('user_type', user_type)
		}
		else  {
			return error("Action name not recognised: ${actionname}.")
		}
	}
}