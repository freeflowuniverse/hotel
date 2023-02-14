module reception

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.finance

import json

// todo all the help flows

pub struct ReceptionActor {
	name string = 'hotel.reception'
	employee_ids = []string
	guest_registrations map[string]string // where string1 is guest code and string2 is employee_id // todo make struct so guest can checkout
	complaints map[string]common.Message // where string is message id 
	guest_payments map[string]finance.Transaction
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
		'register_guest_flow' {
			actor.register_guest_flow(job)!
		}
		'take_guest_payment_flow' {
			actor.take_guest_payment_flow(job)!
		}
		'help_flow' {
			actor.help_flow(job)!
		}
		else {
			error('could not find employee action for job:\n${job}')
			return
		}
	}
}

fn (actor ReceptionActor) register_guest (guest person.Person, employee_id string) !string {
	
	j_args := params.Params{}

	j_args.kwarg_add('guest', json.encode(guest))

	job := actor.baobab.job_new(
		action: 'hotel.guest.add_guest' //todo
		args: j_args
	)!

	response := actor.baobab.job_schedule_wait(job, 0)!

	guest_code := response.result.get('guest_code')
	if guest_code != '' && response.state != .error {
		actor.guest_registrations[guest_code] = employee_id
		return guest_code
	}
	return error("Failed to add guest")
}



