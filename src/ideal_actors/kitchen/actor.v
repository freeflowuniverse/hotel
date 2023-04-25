module kitchen

import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.common
import json

pub struct KitchenActor {
	id      string
	kitchen IKitchen
	baobab  baobab_client.Client
}

fn (actor KitchenActor) run() {
}

fn (actor KitchenActor) execute(mut job ActionJob) ! {
	match actionname {
		'get_product' {
			product_id := job.args.get('product_id')!
			product := actor.kitchen.get_product(product_id)
			job.result.kwarg_add('product', json.encode(product))
		}
		'get_products' {
			product_list := actor.kitchen.get_products()
			job.result.kwarg_add('product_list', json.encode(product_list))
		}
		'order' {
			order := json.decode(common.Order, job.args.get('order')!)
			actor.kitchen.order(order)
		}
		'get' {
			encoded_kitchen := actor.kitchen.get()
			job.result.kwarg_add('encoded_kitchen', encoded_kitchen)
		}
		else {
			job.state = .error
		}
	}
}
