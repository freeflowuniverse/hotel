module supervisor

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.actors.user.user_client

struct SupervisorActor {
	id	string
	supervisor	ISupervisor
	baobab baobab_client.Client
}

fn (actor SupervisorActor) run () {

}

fn (actor SupervisorActor) execute (mut job ActionJob) ! {
	match actionname {
		'create_user' {
			user_ := json.decode(user_client.IClientUser, job.args.get('user_')!)
			actor.supervisor.create_user(user_)
		}
		'designate_access' {
			actor.supervisor.designate_access()
		}
		'get_address' {
			actor_name := job.args.get('actor_name')!
			actor_id := job.args.get('actor_id')!
			string := actor.supervisor.get_address(actor_name, actor_id)
			job.result.kwarg_add('string', string)
		}
		'get_address_book' {
			actor_name := job.args.get('actor_name')!
			string := actor.supervisor.get_address_book(actor_name)
			job.result.kwarg_add('string', string)
		}
		'find_user' {
			identifier := job.args.get('identifier')!
			identifier_type := job.args.get('identifier_type')!
			iclientuser, string := actor.supervisor.find_user(identifier, identifier_type)
			job.result.kwarg_add('iclientuser', json.encode(iclientuser))
			job.result.kwarg_add('string', string)
		}
		'get' {
			supervisor_id := job.args.get('supervisor_id')!
			encoded_supervisor := actor.supervisor.get(supervisor_id)
			job.result.kwarg_add('encoded_supervisor', encoded_supervisor)
		}
		else {job.state = .error}
	}
}