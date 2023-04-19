module user_client

import json

import freeflowuniverse.crystallib.params
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.actors.supervisor.supervisor_client
import freeflowuniverse.hotel.library.models
import freeflowuniverse.hotel.actors.user

pub struct UserClient {
	user_address string
}

pub fn new(user_id string) !UserClient {
	supervisor := supervisor_client.new("0")
	user_address := supervisor.get_address("user", user_id)!
	return UserClient{
		baobab: baobab_client.new()
	}
}

pub fn (client UserClient) get (identifier string, identifier_type string, ) !(user.User, string, ) {
	j_args := params.Params{}
	j_args.kwarg_add('identifier', identifier)
	j_args.kwarg_add('identifier_type', identifier_type)
	job := flows.baobab.job_new(
		action: 'hotel.user.get'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode(user.User, response.result.get('user')!)!, response.result.get('user_type')!
}

pub fn (client UserClient) edit (attribute string, value string, ) ! {
	j_args := params.Params{}
	j_args.kwarg_add('attribute', attribute)
	j_args.kwarg_add('value', value)
	job := flows.baobab.job_new(
		action: 'hotel.user.edit'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

pub fn (client UserClient) start_app (user_id string, ) ! {
	j_args := params.Params{}
	j_args.kwarg_add('user_id', user_id)
	job := flows.baobab.job_new(
		action: 'hotel.user.start_app'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return
}

