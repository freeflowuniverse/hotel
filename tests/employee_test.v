module tests

import freeflowuniverse.hotel.employee
import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.hotel.library.person
import freeflowuniverse.baobab.actor
import freeflowuniverse.baobab.actionrunner
import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.processor
import freeflowuniverse.crystallib.params

import json

fn testsuite_begin() ! {

	// create baobab, actionrunner and processor
	mut b := client.new()!
	mut employeeactor := employee.new()!
	mut ar := actionrunner.new(b, [&actor.IActor(employeeactor)])
	mut processor_ := processor.Processor{}

	// concurrently run actionrunner, processor, and external client
	spawn (&ar).run()
	spawn (&processor_).run()
}

fn test_employee_actor() {
	mut b := client.new() or { panic(err) }
	mut employee_person := person.Person{}

	d_person := dummy_person()
	employee_id := ae_test(mut b, json.encode(d_person)) or {panic("ae_test: $err")}
	assert employee_id.len == 1

	// todo deal with errors here
	employee_person = sepfh_test(mut b, 'johnsmith', 'telegram') or {panic("sgp_test: $err")}
	assert employee_person == d_person
}

fn ae_test (mut b client.Client, employee_person string) !string {
	mut job := create_job([['employee_person', employee_person]], 'employee.add_employee')!
	response := b.job_schedule_wait(mut job, 0)!
	return response.result.get('employee_id')!
}

fn sepfh_test (mut b client.Client, user_id string, channel_type string) !person.Person {
	mut job := create_job([['user_id', user_id],['channel_type', channel_type]], 'guest.send_guest_code_from_handle') or {return error("Failed to create job: $err")}
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	return json.decode(person.Person, response.result.get('employee_person')!)!
}

// TODO test get handles from ids

/*
pub fn (mut actor EmployeeActor) get_handles_from_ids (mut job ActionJob) ! {
	employee_ids := json.decode([]string, job.args.get('employee_ids'))
	channel_type := job.args.get('channel_type')!

	mut handles := []string{}

	employees := actor.employees.filter(it.id in employee_ids)

	for employee in employees {
		handles << match channel_type {
			'telegram' {employee.telegram_username}
		}
	}
	
	job.result.kwarg_add('handles', json.encode(handles))
}
*/


fn create_job (pairs [][]string, actor_function string) !ActionJob {
	mut j_args := params.Params{}
	for pair in pairs {
		j_args.kwarg_add(pair[0], pair[1])
	}
	return jobs.new(
		action: 'hotel.$actor_function'
		args: j_args
	)!
}

fn dummy_person () person.Person {
	return person.Person{
		id: '23'
		firstname: 'John'
		lastname: 'Smith'
		email: 'john@gmail.com'
		telegram_username: 'johnsmith'
		phone_number: '0779876543'
	}
}
