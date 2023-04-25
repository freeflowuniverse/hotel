module user_client

import user_model
import time
import json
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.actors.supervisor.supervisor_client
import freeflowuniverse.crystallib.params

pub interface IClientUser {
	telegram_username string
	id string
	firstname string
	lastname string
	email string
	phone_number string
	date_of_birth time.Time
	allergies string
	preferred_contact string
	digital_funds f64
}

pub struct UserClient {
	user_address string
	baobab       baobab_client.Client
}

pub fn new(user_id string) !UserClient {
	supervisor := supervisor_client.new('0') or {
		return error('Failed to create a new supervisor client with error: ${err}')
	}
	user_address := supervisor.get_address('user', user_id)!
	return UserClient{
		baobab: baobab_client.new()
	}
}

pub fn (userclient UserClient) get() !IClientUser {
	j_args := params.Params{}
	job := flows.baobab.job_new(
		action: 'hotel.user.get'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	if decoded := json.decode(user_model.Guest, response) {
		return decoded
	}
	if decoded := json.decode(user_model.Employee, response) {
		return decoded
	}
	return error('Failed to decode user type')
}
