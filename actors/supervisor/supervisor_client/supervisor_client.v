module supervisor_client

import json

import freeflowuniverse.crystallib.params
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.actors.supervisor.supervisor_client
import freeflowuniverse.hotel.actors.supervisor.model

pub interface IClientSupervisor {
mut:
	address_books	[]model.AddressBook
}

pub struct SupervisorClient {
	supervisor_address string
}

pub fn new(supervisor_id string) !SupervisorClient {
	supervisor := supervisor_client.new("0")
	supervisor_address := supervisor.get_address("supervisor", supervisor_id)!
	return SupervisorClient{
		baobab: baobab_client.new()
	}
}

pub fn (client SupervisorClient) create_user (user_ user_client.IClientUser) ! {
	j_args := params.Params{}
	j_args.kwarg_add('user_', json.encode(user_))
	job := flows.baobab.job_new(
		action: 'hotel.supervisor.create_user'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

pub fn (client SupervisorClient) designate_access () ! {
	j_args := params.Params{}
	job := flows.baobab.job_new(
		action: 'hotel.supervisor.designate_access'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

pub fn (client SupervisorClient) get_address (actor_name string, actor_id string) !string  {
	j_args := params.Params{}
	j_args.kwarg_add('actor_name', actor_name)
	j_args.kwarg_add('actor_id', actor_id)
	job := flows.baobab.job_new(
		action: 'hotel.supervisor.get_address'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return response.result.get('string')!
}

pub fn (client SupervisorClient) get_address_book (actor_name string) !string  {
	j_args := params.Params{}
	j_args.kwarg_add('actor_name', actor_name)
	job := flows.baobab.job_new(
		action: 'hotel.supervisor.get_address_book'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return response.result.get('string')!
}

pub fn (client SupervisorClient) find_user (identifier string, identifier_type string) !(user_client.IClientUser, string) {
	j_args := params.Params{}
	j_args.kwarg_add('identifier', identifier)
	j_args.kwarg_add('identifier_type', identifier_type)
	job := flows.baobab.job_new(
		action: 'hotel.supervisor.find_user'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode(user_client.IClientUser, response.result.get('iclientuser')!)!, response.result.get('string')!
}

pub fn (client SupervisorClient) get (supervisor_id string) !IClientSupervisor  {
	j_args := params.Params{}
	j_args.kwarg_add('supervisor_id', supervisor_id)
	job := flows.baobab.job_new(
		action: 'hotel.supervisor.get'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	if decoded := json.decode(model.Supervisor, response) {
		return decoded
	}
	return error("Failed to decode supervisor type")
}

