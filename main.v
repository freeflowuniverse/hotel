module main

// import freeflowuniverse.hotel.library.product
// import freeflowuniverse.hotel.library.common
// import freeflowuniverse.hotel.library.finance
// import freeflowuniverse.baobab.jobs {ActionJob}
// import freeflowuniverse.hotel.guest
// import freeflowuniverse.hotel.actors.kitchen.kitchen_client
import freeflowuniverse.hotel.actor_builder
import os

const actors = ['user', 'supervisor', 'kitchen']

fn main() {
	dir_path := os.dir(@FILE) + '/actors'
	for actor in ['supervisor','kitchen'] {
		mut builder := actor_builder.new(dir_path + '/' + actor) or { panic("Failed to generate a new builder for $actor with error: $err") }
		builder.build() or { panic("Failed to execute build with error: $err") }
	}

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