module flows

import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.baobab.client

import time

struct GuestFlows {
	baobab: client.Client
}

pub fn new_flows() GuestFlows {
	return GuestFlows{
		baobab: client.new()
	}
}

fn (mut flows GuestFlows) execute (actionname string, job ActionJob) {
	match actionname {
		'order_product' {
			flows.order_product(job)!
		}
		'view_outstanding' {
			flows.outstanding(job)!
		}
		'get_code' {
			flows.get_code(job)!
		}
		'cancel_order' {
			flows.cancel_order
		}
		// TODO
		// 'help' {
		// 	actor.help(job)!
		// }
		else {
			error('could not find guest action for job:\n${job}')
			return
		}
	}
}



