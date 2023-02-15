module reception

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.baobab.client
import freeflowuniverse.crystallib.params

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
		'check_in' {
			actor.check_in(mut job)!
		}
		'check_out' {
			actor.check_out(mut job)!
		}
		else {
			error('could not find reception action for job:\n${job}')
			return
		}
	}
}

fn (mut actor ReceptionActor) register_guest (mut job ActionJob) ! {
	
	employee_id := job.args.get('employee_id')!

	mut j_args := params.Params{}
	j_args.kwarg_add('guest_person', job.args.get('guest_person')!)
	mut n_job := actor.baobab.job_new(
		action: 'hotel.guest.add_guest'
		args: j_args
	)!

	// response := actor.baobab.job_schedule_wait(mut n_job, 1)!
	// if response.state == .error {
	// 	return error("Failed to register guest with guest actor")
	// }
	// guest_code := response.result.get('guest_code')!
	guest_code := 'ABCD'
	actor.guest_registrations << GuestRegistration{
		employee_id: employee_id
		guest_code: guest_code
	}
		
	job.result.kwarg_add('guest_code', guest_code)	
}


fn (mut actor ReceptionActor) check_in (mut job ActionJob) ! {
	
	employee_id := job.args.get('employee_id')!
	guest_code := job.args.get('guest_code')!

	for mut reg in actor.guest_registrations {
		if reg.guest_code == guest_code {
			reg.check_in_employee_id = employee_id
			reg.check_in = time.now()
		}
	}
}

fn (mut actor ReceptionActor) check_out (mut job ActionJob) ! {
	
	employee_id := job.args.get('employee_id')!
	guest_code := job.args.get('guest_code')!

	for mut reg in actor.guest_registrations {
		if reg.guest_code == guest_code {
			reg.check_out_employee_id = employee_id
			reg.check_out = time.now()
		}
	}
}