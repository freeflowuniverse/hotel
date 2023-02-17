module flows

import freeflowuniverse.hotel.library.person

import json

fn (flows HRFlows) register (employee_person person.Person, employee_id string) ! {

	j_args := params.Params{}

	j_args.kwarg_add('employee_person', json.encode(employee_person))
	j_args.kwarg_add('employee_id', employee_id)

	job := flows.baobab.job_new(
		action: 'hotel.hr.register_employee'
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!

	if response.state != .done {
		return error("Failed to register employee")
	}
}
