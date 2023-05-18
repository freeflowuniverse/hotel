module supervisor_builder


pub fn (sb SupervisorBuilder) create_client () {

	mut create_functions := ''
	for name in sb.actors.map(it.name) {
		create_functions += "
pub fn (mut supervisorclient SupervisorClient) create_${name}(${name}_instance ${name}_model.IModel${name.capitalize()}) ! {
	mut j_args := params.Params{}
	j_args.kwarg_add('${name}_instance', json.encode(${name}_instance))
	mut job := supervisorclient.baobab.job_new(
		action: 'hotel.supervisor.create_${name}'
		args: j_args
	)!
	response := supervisorclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}
"	}

	client_content := "module supervisor_client

${sb.actors.map('import ${sb.actors_root}.${it.name}.${it.name}_model').join_lines()}
import ${sb.actors_root}.supervisor.supervisor_model
import json
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.crystallib.params

pub struct SupervisorClient {
pub mut:
	supervisor_address string
	baobab             baobab_client.Client
}

pub fn new() !SupervisorClient {
	return SupervisorClient{
		supervisor_address: '0'
		baobab: baobab_client.new('0') or {return error('Failed to create new baobab client with error: \n\$err')}
	}
}

${create_functions}

pub fn (mut supervisorclient SupervisorClient) get_address(actor_name string, actor_id string) !string {
	mut j_args := params.Params{}
	j_args.kwarg_add('actor_name', actor_name)
	j_args.kwarg_add('actor_id', actor_id)
	mut job := supervisorclient.baobab.job_new(
		action: 'hotel.supervisor.get_address'
		args: j_args
	)!
	response := supervisorclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return response.result.get('address')!
}

pub fn (mut supervisorclient SupervisorClient) get_address_book(actor_name string) !map[string]string {
	mut j_args := params.Params{}
	j_args.kwarg_add('actor_name', actor_name)
	mut job := supervisorclient.baobab.job_new(
		action: 'hotel.supervisor.get_address_book'
		args: j_args
	)!
	response := supervisorclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode(map[string]string, response.result.get('address_book')!)!
}

pub fn (mut supervisorclient SupervisorClient) edit_address_book(actor_name string, address_book map[string]string) ! {
	mut j_args := params.Params{}
	j_args.kwarg_add('actor_name', actor_name)
	j_args.kwarg_add('address_book', json.encode(address_book))
	mut job := supervisorclient.baobab.job_new(
		action: 'hotel.supervisor.get_address_book'
		args: j_args
	)!
	response := supervisorclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

pub fn (mut supervisorclient SupervisorClient) get() !IModelSupervisor {
	mut j_args := params.Params{}
	mut job := supervisorclient.baobab.job_new(
		action: 'hotel.supervisor.get'
		args: j_args
	)!
	response := supervisorclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	if decoded := json.decode(supervisor_model.Supervisor, response.result.get('encoded_supervisor')!) {
		return decoded
	}
	return error('Failed to decode supervisor type')
}

"

	client_path := sb.dir_path.extend_file('supervisor_client/client.v')!
	ab.append_create_file(mut client_path, client_content, [])!
}
