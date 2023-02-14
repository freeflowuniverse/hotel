module guest

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.product


import json

// todo figure out error messages both in internal functions and errors from other actors
// todo consider putting guest_orders into EmployeeActor not Employee
/*
TODO Flows
- get_work_schedule
- clock_in
- clock_out
- schedule_holiday
- report_sick
TODO internal
- check_if_employee_on_shift
- add_employee
*/

pub struct EmployeeActor {
	name string = 'hotel.employee'
	employees []Employee // where string is guest code
	waiting map[string]
}

pub fn (mut actor EmployeeActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active employee..')
		println(job)
	}

	actionname := job.action.split('.').last()

	match actionname {
		'send_employee_person_from_handle' {
			actor.get_employee_from_telegram(mut job)
		} 
		else {
			error('could not find employee action for job:\n${job}')
			return
		}
	}
}

fn (actor EmployeeActor) send_employee_person_from_handle (job ActionJob) {
	mut found := false 
	channel_type := job.args.get('channel_type')!
	telegram_username := job.args.get('user_id')!
	for employee in actor.employees {
		if employee.telegram_username == telegram_username {
			job.result.kwarg_add('employee', employee.Person)
			found = true
		}
	}
	if found == false {
		job.state = .error
	}
	actor.baobab.job_schedule(job)!
}
