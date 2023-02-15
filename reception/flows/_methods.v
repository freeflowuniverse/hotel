module flows

import freeflowuniverse.hotel.library.person

import json

fn (flows ReceptionFlows) register (guest_person person.Person, employee_id string) !string {

	j_args := params.Params{}

	j_args.kwarg_add('guest_person', json.encode(guest_person))
	j_args.kwarg_add('employee_id', employee_id)

	job := flows.baobab.job_new(
		action: 'hotel.reception.register_guest'
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!

	if response.state == .done {
		return response.result.get('guest_code')
	} else {
		return error("Failed to get guest code")
	}
}

fn (flows ReceptionFlows) check_in (employee_id string, guest_code string) !bool {
	
	j_args := params.Params{}

	j_args.kwarg_add('guest_code', guest_code)
	j_args.kwarg_add('employee_id', employee_id)

	job := flows.baobab.job_new(
		action: 'hotel.reception.check_in'
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!

	if response.state == .done {
		return true
	} 
	return false
} 

fn (flows ReceptionFlows) check_out (employee_id string, guest_code string) !bool {
	
	j_args := params.Params{}

	j_args.kwarg_add('guest_code', guest_code)
	j_args.kwarg_add('employee_id', employee_id)

	job := flows.baobab.job_new(
		action: 'hotel.reception.check_out'
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!

	if response.state == .done {
		return true
	} 
	return false
} 