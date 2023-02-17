module hr

module guest

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.hotel.library.person
import freeflowuniverse.baobab.client

import json
import rand

// todo figure out waiting

// todo figure out how to generate new ids that are unique

// todo order confirmations and cancel order confirmations

// todo remember to set job status to done if they were done succesfully


pub struct HRActor {
	name string = 'hotel.hr'
	employee_ids []string
	employee_register []EmployeeOverview
	baobab client.Client
}

struct EmployeeOverview {
	registerer_id string
	employee_id string
	actor_ids []string // list of ids where that employee works
	active bool
	employee_reports []EmployeeReport
}

struct EmployeeReport {
	// todo 
}

pub fn new() !HRActor {
	return HRActor{
		baobab: client.new()!
	}
}

pub fn (mut actor HRActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active guest..')
		println("Execute Input:")
		println(job)
	}
	// used to initialize gitstructure by default
	// if git init action isn't the first job

	actionname := job.action.split('.').last()

	match actionname {
		'register_employee' {
			actor.register_employee(mut job)!
		}
		'make_employee_redundant' {
			actor.make_employee_redundant(mut job)!
		}
		else {
			error('could not find hr action for job:\n${job}')
			return
		}
	}

	$if debug {
		println("Execute Output:")
		println(job)
	}
}




/*
- hiring and firing
- submit report on an employee
- ...
*/

// FROM USER
fn (mut actor HRActor) register_employee (mut job ActionJob) ! {

}

// FROM USER
fn (mut actor HRActor) make_employee_redundant (mut job ActionJob) ! {

}

 
