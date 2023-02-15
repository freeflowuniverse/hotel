module tests

import freeflowuniverse.hotel.reception
import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.baobab.actor
import freeflowuniverse.baobab.actionrunner
import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.processor
import freeflowuniverse.crystallib.params
import freeflowuniverse.hotel.library.person

import json

fn testsuite_begin() ! {
	// create baobab, actionrunner and processor
	mut b := client.new()!
	mut receptionactor := reception.new()!
	mut ar := actionrunner.new(b, [&actor.IActor(receptionactor)])
	mut processor := processor.Processor{}

	// concurrently run actionrunner, processor, and external client
	spawn (&ar).run()
	spawn (&processor).run()
}

fn test_reception_actor() {
	mut b := client.new() or { panic(err) }
	d_person := dummy_person() 
	// todo will need to mock the guest actor to respond
	guest_code := rg_test(mut b, '27', d_person) or {panic("rg_test: $err")}
	// assert guest_code.len == 4
 
	// assert ci_test(mut b, '27', guest_code) or {panic("ci_test: $err")} == true 
	// assert co_test(mut b, '27', guest_code) or {panic("co_test: $err")} == true
}


fn rg_test (mut b client.Client, employee_id string, guest_person person.Person) !string {
	mut job := create_job([['employee_id', employee_id], ['guest_person', json.encode(guest_person)]], 'reception.register_guest')!
	// response := b.job_schedule_wait(mut job, 0)!
	// return response.result.get('guest_code')!
	return ''
}

// todo check that internal state is valid
fn ci_test (mut b client.Client, employee_id string, guest_code string) !bool {
	mut job := create_job([['employee_id', employee_id], ['guest_code', guest_code]], 'reception.check_in')!
	response := b.job_schedule_wait(mut job, 0)!
	if response.state == .done {
		return true
	} else {
		return false
	}
}

// todo check that internal state is valid
fn co_test (mut b client.Client, employee_id string, guest_code string) !bool {
	mut job := create_job([['employee_id', employee_id], ['guest_code', guest_code]], 'reception.check_out')!
	response := b.job_schedule_wait(mut job, 0)!
	if response.state == .done {
		return true
	} else {
		return false
	}
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
