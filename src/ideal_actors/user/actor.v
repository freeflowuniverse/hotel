module user

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.baobab.client as baobab_client

pub struct UserActor {
	id     string
	user   IUser
	baobab baobab_client.Client
}

fn (actor UserActor) run() {
}

fn (actor UserActor) execute(mut job ActionJob) ! {
	match actionname {
		'get' {
			encoded_user := actor.user.get()
			job.result.kwarg_add('encoded_user', encoded_user)
		}
		else {
			job.state = .error
		}
	}
}
