module supervisor_client

import freeflowuniverse.hotel.src.ideal_actors.user.user_model
import freeflowuniverse.hotel.src.ideal_actors.kitchen.kitchen_model
import supervisor_model
import json
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.crystallib.params

pub interface IClientSupervisor {
mut:
	address_books []supervisor_model.AddressBook
}

pub struct SupervisorClient {
pub mut:
	supervisor_address string
	baobab             baobab_client.Client
}

pub fn new() !SupervisorClient {
	return SupervisorClient{
		supervisor_address: '0'
		baobab: baobab_client.new('0') or {return error("Failed to create new baobab client with error: \n$err")}
	}
}

pub fn (mut supervisorclient SupervisorClient) create_user(user_instance user_model.IModelUser) ! {
	mut j_args := params.Params{}
	j_args.kwarg_add('user_instance', json.encode(user_instance))
	mut job := supervisorclient.baobab.job_new(
		action: 'hotel.supervisor.create_user'
		args: j_args
	)!
	response := supervisorclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

pub fn (mut supervisorclient SupervisorClient) create_kitchen (kitchen_instance kitchen_model.IModelKitchen) ! {
	mut j_args := params.Params{}
	j_args.kwarg_add('kitchen_instance', json.encode(kitchen_instance))
	mut job := supervisorclient.baobab.job_new(
		action: 'hotel.supervisor.create_kitchen'
		args: j_args
	)!
	response := supervisorclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

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

pub fn (mut supervisorclient SupervisorClient) get() !IClientSupervisor {
	mut j_args := params.Params{}
	mut job := supervisorclient.baobab.job_new(
		action: 'hotel.supervisor.get'
		args: j_args
	)!
	response := supervisorclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error { // todo this will need to be fixed up
		return error('Job returned with an error')
	}
	if decoded := json.decode(supervisor_model.Supervisor, response.result.get('encoded_supervisor')!) {
		return decoded
	}
	return error('Failed to decode supervisor type')
}
