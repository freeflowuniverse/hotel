module kitchen

import freeflowuniverse.hotel.actors.kitchen.kitchen_model
import json


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



pub interface IKitchen {
mut:
	name	string
	access_levels	map[string][]string
	storage_id	string
	products	[]product.Product
	ingredients	[]product.Product
	telegram_channel	string
	orders	[]common.Order	
}

pub fn (mut ikitchen IKitchen) get () !string {
	if ikitchen is kitchen_model.Kitchen {
		return json.encode(ikitchen)
	}
	panic('This point should never be reached. There is an issue with the code!')
}

pub fn (mut ikitchen IKitchen) get_attribute (attribute_name string, encoded_value string) !string {
	match attribute_name {
		'name' { return json.encode(ikitchen.name) }
		'access_levels' { return json.encode(ikitchen.access_levels) }
		'storage_id' { return json.encode(ikitchen.storage_id) }
		'products' { return json.encode(ikitchen.products) }
		'ingredients' { return json.encode(ikitchen.ingredients) }
		'telegram_channel' { return json.encode(ikitchen.telegram_channel) }
		'orders' { return json.encode(ikitchen.orders) }
		else {
			
			return error("Attribute name '${attribute_name}' not recognised by this user instance!")
		}
	}
}

pub fn (mut ikitchen IKitchen) edit_attribute (attribute_name string, encoded_value string) ! {
	match attribute_name {
		'name' { ikitchen.name = encoded_value.trim('"').trim("'") }
		'access_levels' { ikitchen.access_levels = json.decode(map[string][]string, encoded_value)! }
		'storage_id' { ikitchen.storage_id = encoded_value.trim('"').trim("'") }
		'products' { ikitchen.products = json.decode([]product.Product, encoded_value)! }
		'ingredients' { ikitchen.ingredients = json.decode([]product.Product, encoded_value)! }
		'telegram_channel' { ikitchen.telegram_channel = encoded_value.trim('"').trim("'") }
		'orders' { ikitchen.orders = json.decode([]common.Order, encoded_value)! }
		else {
			
			return error("Attribute name '${attribute_name}' not recognised by this user instance!")
		}
	}
}