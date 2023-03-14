module guest_client

import json

import freeflowuniverse.crystallib.params
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.person

pub struct GuestClient{}

pub fn new() GuestClient {
	return GuestClient{
		baobab: baobab_client.new()
	}
}

pub fn (client GuestClient) add_guest (
	guest_person person.Person, 
	) !(
		string, 
		string, )
	{
	j_args := params.Params{}
	j_args.kwarg_add('guest_person', json.encode(guest_person))
	job := flows.baobab.job_new(
		action: 'hotel.
		guest.add_guest'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return 
	response.result.get('code')!, 
	response.result.get('name')!, 
}

pub fn (client GuestClient) identify_guest (user_id string, channel_type string, ) !(person.Person, string, ){
	j_args := params.Params{}
	j_args.kwarg_add('user_id', user_id)
	j_args.kwarg_add('channel_type', channel_type)
	job := flows.baobab.job_new(
		action: 'hotel.guest.identify_guest'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return json.decode(person.Person ,response.result.get('guest_person')!)!, response.result.get('guest_code')!, 
}

