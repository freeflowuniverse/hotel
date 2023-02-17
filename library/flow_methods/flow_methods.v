module flow_methods

import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.common
import freeflowuniverse.baobab.client
import freeflowuniverse.crystallib.params

import json

pub fn get_guest (guest_code string, baobab client.Client) !(string, person.Person) {
	j_args := params.Params{}
	j_args.kwarg_add('guest_code', guest_code)
	job := baobab.job_new(
		action: 'hotel.guest.send_guest_person'
		args: j_args
	)!
	response := baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error("Failed to get guest from telegram")
	}
	return json.decode(person.Person, response.result.get('guest_person'))
}

pub fn validate_product_code(code string, baobab client.Client) !bool {
	actor_name := match_code_to_vendor(code)!

	if actor_name == '' { return false }

	response := product.get_product(code[1..(code.len)], actor_name, baobab)
	
	if response.state == .error { return false }
	return true
}

pub fn get_guest_active_orders (guest_code string, baobab client.Client) !map[string]common.Order {
	j_args := params.Params{}
	j_args.kwarg_add('guest_code',guest_code)
	j_args.kwarg_add('active', 'true')
	job := baobab.job_new(
		action: 'hotel.guest.send_guest_orders'
		args: j_args
	)!

	response := baobab.schedule_job_wait(job, 0)!

	if response.state == .error {
		return error("Failed to get guest orders.")
	}

	guest_orders := json.decode([]common.Order, response.result.get('orders'))
	return guest_orders
}

pub fn get_employee_person_from_handle (user_id string, channel_type string, baobab client.Client) !person.Person {
	j_args := params.Params{}
	j_args.kwarg_add('user_id', user_id)
	j_args.kwarg_add('channel_type', channel_type)
	job := baobab.job_new(
		action: 'hotel.employee.send_employee_person_from_handle'
		args: j_args
	)!
	response := baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error("Failed to get employee person from $channel_type user_id: $user_id")
	}
	return json.decode(person.Person, response.result.get('employee'))
}

pub fn validate_guest_code(guest_code string, baobab, client.Client) bool {
	if guest_person := flow_methods.get_guest(guest_code, baobab) {
		return true
	} else {
		return false // todo return error message here
	}
}
