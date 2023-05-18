module kitchen


import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.product

// ui can be included but only for one-off sending of messages
pub fn (kitchen IKitchen) get_product (product_id string) !product.Product {
	product := products.filter(it.id == product_id)
	if product.len == 0 {
		return error("Could not find product.")
	}
	return product[0] // ? Why is this returning product_id
}

// // ui can be included but only for one-off sending of messages
// pub fn (kitchen IKitchen) get_products () ![]product.Product {
// 	return kitchen.products
// }

pub fn (kitchen IKitchen) order (order common.Order) ! {
	// todo maybe perform some validation here?
	kitchen.orders << order
	ui := ui_client.new(kitchen.id, kitchen.telegram_channel)
	ui.send_message(order.stringify()) // todo need to make stringify method
}

fn (kitchen IKitchen) create_product () ! {}

fn (kitchen IKitchen) edit_product () ! {}

fn (kitchen IKitchen) delete_product () ! {}

