module kitchen

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.hotel.library.vendor {VendorMixin}
import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.product

// todo figure out waiting

// todo figure out how to generate new ids that are unique

// todo order confirmations and cancel order confirmations

// todo remember to set job status to done if they were done succesfully

pub struct KitchenActor {
VendorMixin
pub mut:
	storage_id  string // The idea here is to have your menu defined by contents of supply
	products     []product.Product
	ingredients  []product.Product
}

pub fn new() !KitchenActor {
	return KitchenActor{
		name: 'hotel.kitchen'
		baobab: client.new()!
	}
}

pub fn (mut actor KitchenActor) execute (mut job ActionJob) ! {
	$if debug {
		eprintln('active kitchen..')
		println(job)
	}

	actionname := job.action.split('.').last()

	for oj in actor.open_judgements {
		if job.guid in oj.flow_guids {
			actor.confirm_order_cancellation(mut job, oj)!
		}
	}

	match actionname {
		'add_product' {
			actor.products << actor.add_product(mut job, vendor.generate_product_id(actor.products)!)!
		}
		'send_catalogue' {
			actor.send_catalogue(mut job, actor.products)!
		}
		else {
			actor.execute_vendor(mut job)!
		}
	}
}
