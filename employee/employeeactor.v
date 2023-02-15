module employee

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.person
import freeflowuniverse.baobab.client


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
pub mut:
	name string = 'hotel.employee'
	employees []Employee // where string is guest code
	baobab client.Client
}

pub fn new() !EmployeeActor {
	return EmployeeActor{
		baobab: client.new()!
	}
}

pub fn (mut actor EmployeeActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active employee..')
		println(job)
	}

	actionname := job.action.split('.').last()

	match actionname {
		'send_employee_person_from_handle' {
			actor.send_employee_person_from_handle(mut job)!
		} 
		'add_employee' {
			actor.add_employee(mut job)!
		}
		else {
			error('could not find employee action for job:\n${job}')
			return
		}
	}
}

// todo title, actor_ids, etc
pub fn (mut actor EmployeeActor) add_employee (mut job ActionJob) ! {
	mut employee := Employee{
		Person: json.decode(person.Person, job.args.get('employee_person')!)!
	}

	for _, employee_ in actor.employees {
		if employee_.email == employee_.email {
			job.state = .error
			return error("Employee already exists")
		}
	}

	employee.id = actor.generate_employee_id()
	actor.employees << employee

	job.result.kwarg_add('employee_id', employee.id)
}

fn (actor EmployeeActor) send_employee_person_from_handle (mut job ActionJob) ! {
	mut found := false 
	channel_type := job.args.get('channel_type')!
	user_id := job.args.get('user_id')!
	for employee in actor.employees {
		target_user_id := match channel_type {
			'telegram' {employee.telegram_username}
			else {''}
		}
		if user_id == target_user_id {
			job.result.kwarg_add('employee_person', json.encode(employee.Person))
			found = true
		}
	}
	if found == false {
		return error("Failed to find employee")
	}
}

fn (actor EmployeeActor) generate_employee_id () string {
	mut greatest_id := 0
	for employee in actor.employees {
		if employee.id.int() > greatest_id {
			greatest_id = employee.id.int()
		}
	}
	return (greatest_id + 1).str()
}
