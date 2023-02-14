module flowsactor

import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.guest.flows as guest
import freeflowuniverse.hotel.employee.flows as employee
import freeflowuniverse.baobab.jobs { ActionJob }

struct FlowsActor {
	name string = 'hotel.flowsactor'
	references []PersonReference
	baobab client.Client
}

struct PersonReference {
	id string // code for guests, id for employees
	domain string // domain.actor
	// handle keys: 'telegram'
	handles map[string]string // where string is effectively an enum
}


pub fn new() FlowActor {
	actor := FlowActor {
		id: 1
		baobab: client.new()
	}
	return actor
}


pub fn (mut actor FlowActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active guest..')
		println(job)
	}
	// used to initialize gitstructure by default
	// if git init action isn't the first job

	// todo check that this is from an interface
	// todo if yes, the below, else some other means for example order cancellation confirmation

	user_id := job.args.get('user_id')
	channel_type := job.args.get('channel_type')

	mut reference := PersonReference{}

	for reference_ in references {
		if user_id == reference_.handles[channel_type] {
			reference = reference_
		}
	}
	if reference.id == '' {
		job.state = .error
		actor.baobab.job_schedule(job) // ? is this the right way to return error jobs
	}

	actionname := job.action.split('.').last()

	match reference.domain {
		'hotel.guest' {
			g_flows := guest.new_flows()
			spawn g_flows.execute(actionname, job) // ? is this enough? do I need to hold state for them
		}
		'hotel.employee' {
			e_flows := employee.new_flows()
			spawn e_flows.execute(actionname, job)
		}
		else {
			job.state = .error
			actor.baobab.job_schedule(job)
		}
	}
}

// todo functions to add people to this registry