module supervisor_builder

import actor_builder as ab

fn (mut sb SupervisorBuilder) create_actor () ! {
	mut create_branches := ''

	for actor in sb.actors {
		create_branches += "'create_${actor.name}' {\n"
		for flavor in actor.flavors {
			create_branches +=
"	if ${actor.name}_instance := json.decode(${actor.name}_model.${flavor.capitalize()}, job.args.get('${actor.name}_instance')!) {
		actor.supervisor.create_${actor.name}(${actor.name}_instance)!
	}
"
		}
		create_branches += '}\n'
	}

	extra_imports := sb.actors.map('import ${sb.actors_root}.${it.name}.${it.name}_model').join_lines()

	actor_content := "module supervisor

import ${sb.actors_root}.supervisor.supervisor_model
import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.baobab.client as baobab_client
import json
${extra_imports}


pub struct SupervisorActor {
pub mut:
	id         string
	supervisor ISupervisor
	baobab     baobab_client.Client
}

pub fn new() !SupervisorActor {
	supervisor := supervisor_model.Supervisor{}

	for actor in ${sb.actors.map(it.name).str()} {
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
${ab.indent(create_branches, 2)}
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
}"

	mut actor_path := sb.dir_path.extend_file('actor.v')!
	ab.append_create_file(mut actor_path, actor_content, [])!
}
