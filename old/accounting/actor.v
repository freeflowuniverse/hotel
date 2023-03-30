module accounting

import freeflowuniverse.baobab.client

struct Actor {
client.Client
Accounting
mut:
	id string
}

fn run() {
	actor := new()!
	// Populates data
	for {
		job := actor.get_latest_from_queue()
		response := actor.handle_message(job)
	}
}

fn (actor Actor) handle_message (job ActionJob) {
	match job.subject {
		'add_funds_from_internal' {
			actor.add_funds_from_internal(job.params.get('amount'), job.params.get('sender'))
		}
		'employee_login' {
			actor.employee_login(job.params.get('employee_id'))
		}
	}
}