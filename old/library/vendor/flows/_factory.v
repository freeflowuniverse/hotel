module flows

import freeflowuniverse.baobab.jobs {ActionJob}

pub interface IVendorFlows {
	baobab client.Client
	actor_name string
}

pub fn (flows IVendorFlows) execute (mut job ActionJob) ! {
	match actionname {
		'add_product' {
			flows.add_product(job)!
		}
		'close_order' {
			flows.close_order(job)!
		}
		'display_orders' {
			flows.display_orders(job)!
		}
		'judge_cancellation' {
			flows.judge_cancellation(job)!
		}
		else {
			error('could not find $vendor.actor_name action for job:\n${job}')
			return
		}
	}
}