

module kitchen

import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.baobab.jobs as baobab_jobs


pub struct KitchenActor {
pub mut:
	id	string
	kitchen	IKitchen
	baobab	baobab_client.Client	
}

pub fn new (kitchen_instance IKitchen, id string) ! {
	return KitchenActor {
		id: id
		kitchen: kitchen_instance
		baobab: baobab_client.new('0') or {return error('Failed to create baobab client with error: \n$err')}
	}
}

pub fn (mut actor KitchenActor) run ()  {
	for {}
}

pub fn (mut actor KitchenActor) execute (job baobab_jobs.ActionJob) ! {
	actionname := job.action.all_after_last('.')
	match actionname {
		'get_product' {
			product_id := job.args.get('product_id')!
			product := actor.kitchen.get_product(product_id)
			job.result.kwarg_add('product', json.encode(product))
		}
		'order' {
			order := json.decode(common.Order, job.args.get('order')!)!
			actor.kitchen.order(order)
			
		}
		'get' {
			
			encoded_kitchen := actor.kitchen.get()
			job.result.kwarg_add('encoded_kitchen', encoded_kitchen)
		}
		'get_attribute' {
			attribute_name := job.args.get('attribute_name')!
			encoded_value := job.args.get('encoded_value')!
			encoded_attribute := actor.kitchen.get_attribute(attribute_name, encoded_value)
			job.result.kwarg_add('encoded_attribute', encoded_attribute)
		}
		'edit_attribute' {
			attribute_name := job.args.get('attribute_name')!
			encoded_value := job.args.get('encoded_value')!
			actor.kitchen.edit_attribute(attribute_name, encoded_value)
			
		}
		'delete' {
			panic('This actor has been deleted!')
		}
		else { return error("Could not identify the method name: '$actionname' !") }
	}
}