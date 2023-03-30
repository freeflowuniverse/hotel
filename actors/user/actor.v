module user 

import freeflowuniverse.hotel.library.models
import freeflowuniverse.baobab.client as baobab_client

struct UserActor {
	id string
	user IUser
	baobab baobab_client.Client
}

fn new (user models.IUser, id string) UserActor {
	return UserActor{
		id: id
		user: user
		baobab: baobab_client.new()
	}
}

// main function that listens and never stops running
fn (actor UserActor) run () {
	// needs to perform actionrunner infinite for loop
}

// function that takes incoming jobs and executes on the response
fn (actor UserActor) execute (mut job ActionJob) ! {
	match actionname {
		'get' {
			identifier := job.params.get('identifier')!
			identifier_type := job.params.get('identifier_type')!
			user, user_type := actor.user.get(identifier, identifier_type)!
			job.result.kwarg_add('user', json.encode(User(user)))
			job.result.kwarg_add('user_type', user_type)
		}
		'start_app' {
			user_id := job.params.get('user_id')
			spawn actor.user.start_app(user_id)
		}
		'edit' {
			attribute := job.params.get('attribute')
			value := job.params.get('value')
			actor.user.edit(attribute, value)!
		}
	}
}



