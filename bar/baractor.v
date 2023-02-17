module bar

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.vendor {VendorMixin}
import freeflowuniverse.baobab.client

// todo figure out waiting

// todo figure out how to generate new ids that are unique

pub struct BarActor {
VendorMixin
	bars []Bar
}

pub fn new() !BarActor {
	return BarActor{
		name: 'hotel.bar'
		baobab: client.new()!
	}
}

pub fn (mut actor BarActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active bar..')
		println(job)
	}
	// used to initialize gitstructure by default
	// if git init action isn't the first job

	actionname := job.action.split('.').last()

	for oj in actor.open_judgements {
		if job.guid in oj.flow_guids {
			actor.confirm_order_cancellation(mut job, oj)!
		}
	}

	match actionname {
		'bar_method' {
		}
		else {
			actor.execute_vendor(mut job)!
		}
	}
}