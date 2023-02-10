module flows 

import freeflowuniverse.crystallib.params
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.person

fn (flows EmployeeFlows) validate_guest_code(guest_code string) !bool {
	j_args := params.Params{}
	j_args.kwarg_add('guest_code', guest_code)
	job := flows.baobab.job_new(
		action: 'hotel.guest.validate_guest_code' //todo
		args: j_args
	)!
	response := flows.baobab.schedule_job_wait(job, 100)! //? what should the timeout be?
	if response.args.get('guest_code') == 'true' {
		return true
	} else {
		return false
	}
}

fn (flows EmployeeFlows) get_guest_code (firstname string, lastname string, email string) !string {

	j_args := params.Params{}

	j_args.kwarg_add('firstname', firstname)
	j_args.kwarg_add('lastname', lastname)
	j_args.kwarg_add('email', email)

	job := flows.baobab.job_new(
		action: 'hotel.guest.get_guest_code' //todo
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!
	if response.args.exists('guest_code'){
		return response.args.get('guest_code')
	} else {
		return error("Guest does not exist")
	}
}

fn (flows EmployeeFlows) validate_product_code(code string) !bool {
	actor_name := match code[0].ascii_str() {
		'K' {'kitchen'}
		'B' {'bar'}
		else {''}
	}

	if actor_name == '' { return false }

	response := common.get_product(code[1..(code.len)], actor_name)
	
	if response.state == .error { return false }
	return true
}


fn (flows EmployeeFlows) get_employee_from_telegram (user_id string) !person.Person {
	j_args := params.Params{}
	j_args.kwarg_add('telegram_username', user_id)
	job := flows.baobab.job_new(
		action: 'hotel.employee.get_employee_from_telegram'
		args: j_args
	)!
	response := flows.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error("Failed to get employee from telegram")
	}
	return response.response.get('employee')
}


fn (flows EmployeeFlows) get_guest_person (guest_code string) !Person {

	j_args := params.Params{}
	j_args.kwarg_add('guest_code', guest_code)
	job := flows.baobab.job_new(
		action: 'hotel.guest.get_guest_person' //todo
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!

	if response.state == .error {
		return error("Failed to get guest.")
	}

	guest_person := json.decode(person.Person, response.result.get('guest'))
	return guest_person	
}

fn (flows EmployeeFlows) get_guest_orders (guest_code string) map[string]common.Order {
	j_args := params.Params{}
	j_args.kwarg_add('guest_code',guest_code)
	job := flows.baobab.job_new(
		action: 'hotel.guest.get_guest_orders' //todo
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!

	if response.state == .error {
		return error("Failed to get guest orders.")
	}
	// ? should this decoding occur here or in the next stage
	// TODO be consistent for get_employee_from_telegram I return the job not the employee

	guest_orders := json.decode(map[string]common.Order, response.result.get('orders'))
	return guest_orders
}
