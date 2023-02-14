module kitchen

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.person

import json

// todo figure out waiting

// todo figure out how to generate new ids that are unique

// todo order confirmations and cancel order confirmations

// todo remember to set job status to done if they were done succesfully

pub struct KitchenActor {
	name string = 'hotel.kitchen'
	kitchens []Kitchen
}

pub fn (mut actor GuestActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active guest..')
		println(job)
	}
	// used to initialize gitstructure by default
	// if git init action isn't the first job

	actionname := job.action.split('.').last()

	for oj in actor.open_judgements {
		if job.guid in oj.flow_guids {
			actor.confirm_order_cancelled(mut job, oj)
		}
	}

	match actionname {
		'cancel_order' {
			actor.announce_cancellation_request(mut job)
		}
		'order' {
			actor.announce_order(mut job)
		}
		'close_order' {
			actor.close_order(mut job)
		}
		else {
			error('could not find guest action for job:\n${job}')
			return
		}
	}
}