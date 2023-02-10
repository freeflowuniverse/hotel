module flows

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.reception
import freeflowuniverse.hotel.kitchen
import freeflowuniverse.hotel.bar


struct EmployeeFlows {
	baobab: client.Client
}

pub fn new_flows() EmployeeFlows {
	return EmployeeFlows{
		baobab: client.new()
	}
}

fn (mut flows EmployeeFlows) execute (actionname string, job ActionJob) {
	match actionname {
		'reception' {
			r_flows := reception.new_flows()
			r_flows.execute(actionname, job)
		}
		'kitchen' {
			k_flows := kitchen.new_flows()
			k_flows.execute(actionname, job)
		}
		'bar' {
			b_flows := bar.new_flows()
			b_flows.execute(actionname, job)
		}
		'order_guest_product' {
			flows.order_guest_product(job)!
		}
		'cancel_order' {
			flows.cancel_order
		}
		'view_guest_outstanding' {
			flows.guest_outstanding(job)!
		}
		'get_guest_code' {
			flows.get_guest_code(job)!
		}
		// TODO 
		// 'help' {
		// 	flows.help(job)!
		// }
		else {
			error('could not find employee action for job:\n${job}')
			return
		}
	}
}
