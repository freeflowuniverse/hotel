module kitchen 

import freeflowuniverse.hotel.library.common

struct KitchenActor {
	id string
	kitchen IKitchen
	baobab baobab_client.Client
}

// main function that listens and never stops running
fn (actor KitchenActor) run () {
	// needs to perform actionrunner infinite for loop
}

// function that takes incoming jobs and executes on the response
fn (actor KitchenActor) execute (mut job ActionJob) ! {
	// there are many actor_methods ie order
	// but always one flow: main_flow
	match actionname {
		'get_product' {
			product_id := job.args.get('product_id')
			product := actor.kitchen.get_product(product_id)
			job.result.kwarg_add('product', json.encode(product))
		}
		'get_products' {
			products := actor.kitchen.get_products() 
			job.result.kwarg_add('products', json.encode(products))
		}
		'order' {
			order := json.decode(common.Order, job.args.get('order')!)!
			actor.kitchen.order(order)
		}
		'return_state' {
			kitchen := actor.kitchen.return_state()
			job.result.kwarg_add('kitchen', json.encode(kitchen))
		}
		'root_flow' {
			user_id := job.args.get('user_id')
			// TODO consider whether to make this a method rather than a function
			spawn root_flow(user_id, actor.kitchen.id)
		}
		else {

		}
	}
}
