module flows

import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.jobs { ActionJob }


import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance


import time

struct HRFlows {
	baobab: client.Client
}

pub fn new_flows() HRFlows {
	return ReceptionFlows{
		baobab: client.new()
	}
}

fn (mut flows HRFlows) execute (actionname string, job ActionJob) {
	match actionname {
		'onboard_employee' {
			flows.onboard_employee(job)!
		}
		'make_employee_redundant' {
			flows.make_employee_redundant(job)!
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



