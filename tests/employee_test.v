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
	mut processor := processor.Processor{}

	// concurrently run actionrunner, processor, and external client
	spawn (&ar).run()
	spawn (&processor).run()
}

fn test_employee_actor() {
	mut b := client.new() or { panic(err) }
	mut employee_person := person.Person{}

	d_person := dummy_person()
	employee_id := ae_test(mut b, json.encode(d_person)) or {panic("ae_test: $err")}
	assert employee_id.len == 1

	// todo deal with errors here
	println("BEGIN")
	// employee_person = sepfh_test(mut b, 'johnsmith', 'telegram') or {panic("sgp_test: $err")}
	println("MIDDLE")
	// assert employee_person == d_person
	println("END")
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
