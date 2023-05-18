module main

import freeflowuniverse.hotel.actor_builder
import freeflowuniverse.hotel.supervisor_builder
import os

const actors = ['user', 'kitchen']

fn main() {
	actor_dir_path := os.dir(@FILE) + '/actors'
	actors_root := 'freeflowuniverse.hotel.actors'
	mut sb := supervisor_builder.new_supervisor([]supervisor_builder.Actor{}, actor_dir_path + '/supervisor', actors_root)!

	for actor in actors {
		mut builder := actor_builder.new_actor(actor_dir_path + '/' + actor, actors_root) or { panic("Failed to generate a new builder for $actor with error: $err") }
		builder.build() or { panic("Failed to execute build with error: $err") }
		sb.register(builder)
	}

	sb.build()!
}


/*
order1 := common.Order{
	id: '12'
	for_id: '3'
	orderer_id: 'ASD'
	start: time.now()
	method: .create
	product_amounts: [product.ProductAmount{
		quantity: '2'
		total_price: finance.Price{
			val: 20
			currency: finance.Currency{
				name: 'USD'
				usdval: 1
			}
		}
		product: product.Product{
			id: 'R12'
			name: 'Chicken Curry'
			description: 'A delicious chicken curry served with vegetables'
			state: .ok
			price: finance.Price{
				val: 10
				currency: finance.Currency{
					name: 'USD'
					usdval: 1
				}
			}
			unit: .units
			variable_price: true
		}
	}]
	note: 'This is a sample note'
	additional_attributes: [common.Attribute{
		key: 'room_service'
		value: 'true'
		value_type: 'bool'
	}]
	order_status: .closed
	target_actor: 'restaurant'
}
order2 := common.Order{
	id: '12'
	for_id: '3'
	orderer_id: 'ASD'
	start: time.now()
	method: .create
	product_amounts: [product.ProductAmount{
		quantity: '1'
		total_price: finance.Price{
			val: 20
			currency: finance.Currency{
				name: 'USD'
				usdval: 1
			}
		}
		product: product.Product{
			id: 'R12'
			name: 'Vegetable Soup'
			description: 'A delicious chicken curry served with vegetables'
			state: .ok
			price: finance.Price{
				val: 10
				currency: finance.Currency{
					name: 'USD'
					usdval: 1
				}
			}
			unit: .units
			variable_price: true
		}
	}]
	note: 'This is a sample note'
	additional_attributes: [common.Attribute{
		key: 'room_service'
		value: 'true'
		value_type: 'bool'
	}]
	order_status: .open
	target_actor: 'restaurant'
}
*/