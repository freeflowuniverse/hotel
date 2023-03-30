module flows

import freeflowuniverse.hotel.library.person

import json

fn (flows ReceptionFlows) register (guest_person person.Person, employee_id string) !string {

	mut j_guest_args := params.Params{}
	j_guest_args.kwarg_add('guest_person', json.encode(guest_person))
	mut guest_job := actor.baobab.job_new(
		action: 'hotel.guest.add_guest'
		args: j_guest_args
	)!

	response := actor.baobab.job_schedule_wait(mut guest_job, 0)!
	if response.state != .done {
		return error("Failed to register guest with guest actor")
	}

	mut j_reception_args := params.Params{}

	j_reception_args.kwarg_add('guest_person', json.encode(guest_person))
	j_reception_args.kwarg_add('employee_id', employee_id)
	j_reception_args.kwarg_add('guest_code', guest_code)

	reception_job := flows.baobab.job_new(
		action: 'hotel.reception.register_guest'
		args: j_reception_args
	)!

	response = flows.baobab.schedule_job_wait(reception_job, 0)!

	if response.state == .done {
		return guest_code
	} else {
		return error("Failed to register guest")
		// todo this is problematic because the guest is both registered and not
	}
}

fn (flows ReceptionFlows) check_in (employee_id string, guest_code string) !bool {
	
	j_args := params.Params{}

	j_args.kwarg_add('guest_code', guest_code)
	j_args.kwarg_add('employee_id', employee_id)

	job := flows.baobab.job_new(
		action: 'hotel.reception.check_in_guest'
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
		action: 'hotel.reception.check_out_guest'
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!

	if response.state == .done {
		return true
	} 
	return false
} 