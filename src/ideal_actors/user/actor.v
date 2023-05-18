module user

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.baobab.client as baobab_client

pub struct UserActor {
pub mut:
	id     string
	user   IUser
	baobab baobab_client.Client
}

pub fn new (user_instance IUser, id string) !UserActor {
	return UserActor {
		id: id
		user: user_instance
		baobab: baobab_client.new('0') or {return error("Failed to create baobab client with error: \n$err")}
	}
}

fn (actor UserActor) run() {
	for {}
}

fn (mut actor UserActor) execute(mut job ActionJob) ! {
	
	match actionname {
		'get' {
			encoded_user := actor.user.get()!
			job.result.kwarg_add('encoded_user', encoded_user)
		}
		'get_attribute' {
			attribute_name := job.args.get('attribute_name')!
			encoded_attribute := actor.user.get_attribute(attribute_name)!
			job.result.kwarg_add('encoded_attribute', encoded_attribute)
		} // todo add filters
		'edit_attribute' {
			attribute_name := job.args.get('attribute_name')!
			encoded_value := job.args.get('encoded_value')!
			actor.user.edit_attribute(attribute_name, encoded_value)!
		}
		'delete' {
			panic("This actor has been deleted!") //? This will return an error to the client, but this is strange, because an error in this case means a success, but an error can also mean a failure // TODO use exit instead, I think that will work appropriately
		}
		else {
			return error("Could not identify the method name: '$actionname' !")
		}
	}
}

