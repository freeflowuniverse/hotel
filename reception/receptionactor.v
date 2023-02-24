module reception

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.baobab.client

import time

pub struct ReceptionActor {
pub mut:
	name string = 'hotel.reception'
	employee_ids []string
	guest_registrations []GuestRegistration
	complaints map[string]common.Message // where string is message id 
	guest_payments map[string]finance.Transaction
	baobab client.Client
}

pub fn new() !ReceptionActor {
	return ReceptionActor{
		baobab: client.new()!
	}
}


pub fn (mut actor ReceptionActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active reception..')
		println(job)
	}
	// used to initialize gitstructure by default
	// if git init action isn't the first job

	actionname := job.action.split('.').last()

	match actionname {
		'register_guest' {
			actor.register_guest(mut job)!
		}
		'check_in_guest' {
			actor.check_in_guest(mut job)!
		}
		'check_out_guest' {
			actor.check_out_guest(mut job)!
		}
		else {
			error('could not find reception action for job:\n${job}')
			return
		}
	}
}

fn (mut actor ReceptionActor) register_guest (mut job ActionJob) ! {
	
	employee_id := job.args.get('employee_id')!
	guest_code := job.args.get('guest_code')!

	actor.guest_registrations << GuestRegistration{
		employee_id: employee_id
		guest_code: guest_code
	}
}


fn (mut actor ReceptionActor) check_in_guest (mut job ActionJob) ! {
	
	employee_id := job.args.get('employee_id')!
	guest_code := job.args.get('guest_code')!

	for mut reg in actor.guest_registrations {
		if reg.guest_code == guest_code {
			reg.check_in_employee_id = employee_id
			reg.check_in = time.now()
		}
	}
}

fn (mut actor ReceptionActor) check_out_guest (mut job ActionJob) ! {
	
	employee_id := job.args.get('employee_id')!
	guest_code := job.args.get('guest_code')!

	for mut reg in actor.guest_registrations {
		if reg.guest_code == guest_code {
			reg.check_out_employee_id = employee_id
			reg.check_out = time.now()
		}
	}
}