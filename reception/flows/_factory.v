module flows

import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.jobs { ActionJob }


import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance


import time

struct ReceptionFlows {
	baobab: client.Client
}

pub fn new_flows() ReceptionFlows {
	return ReceptionFlows{
		baobab: client.new()
	}
}

fn (mut flows ReceptionFlows) execute (actionname string, job ActionJob) {
	match actionname {
		'register_guest' {
			flows.register_guest(job)!
		}
		'topup_guest_balance' {
			flows.topup_guest_balance(job)!
		}
		// TODO
		// 'help' {
		// 	actor.help(job)!
		// }
		else {
			error('could not find reception action for job:\n${job}')
			return
		}
	}
}



