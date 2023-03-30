module supervisor_client

import json

import freeflowuniverse.crystallib.params
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.actors.supervisor.supervisor_client
import freeflowuniverse.hotel.actors.supervisor
// import freeflowuniverse.hotel.actors.user
import freeflowuniverse.hotel.library.models

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

pub fn (client SupervisorClient) get_address () !string  {
	j_args := params.Params{}
	job := flows.baobab.job_new(
		action: 'hotel.supervisor.get_address'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return response.result.get('address')!
}

pub fn (client SupervisorClient) get_address_book () !map[string]string  {
	j_args := params.Params{}
	job := flows.baobab.job_new(
		action: 'hotel.supervisor.get_address_book'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return response.result.get('address_book')!
}

pub fn (client SupervisorClient) find_user (identifier string, identifier_type string, ) !(models.IUser, string, ) {
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
	return json.decode(models.IUser, response.result.get('user')!)!, response.result.get('user_type')!
}

