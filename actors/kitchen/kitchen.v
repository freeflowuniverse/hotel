module kitchen

import freeflowuniverse.crystallib.ui.client as ui_client
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.product

// TODO do code generation to put this interface in the client
pub interface IKitchen {
pub mut:
	name string
	access_levels map[string][]string // map[access_level][]user_id
	storage_id string
	products []product.Product
	ingredients []product.Product
	telegram_channel string
	orders []common.Order
}

// ui can be included but only for one-off sending of messages
fn (kitchen IKitchen) get_product (product_id string) !(product.Product, string) {
	product := products.filter(it.id == product_id)
	if product.len == 0 {
		return error("Could not find product.")
	}
	return product[0], product_id
}

// ui can be included but only for one-off sending of messages
fn (kitchen IKitchen) get_products () ![]product.Product {
	return kitchen.products
}

fn (kitchen IKitchen) order (order common.Order) ! {
	// todo maybe perform some validation here?
	kitchen.orders << order
	ui := ui_client.new(kitchen.id, kitchen.telegram_channel)
	ui.send_message(order.stringify()) // todo need to make stringify method
}


fn (kitchen IKitchen) get () !string {
	if kitchen is models.Kitchen {
		return json.encode(target)
	} else if kitchen is models.BrandKitchen {
		return json.encode(target)
	}
}

// fn (kitchen IKitchen) create_product (product product.Product) ! {

// }

// fn (kitchen IKitchen) edit_product (product product.Product) ! {

// }

// fn (kitchen IKitchen) delete_product (product_id string) ! {

// }