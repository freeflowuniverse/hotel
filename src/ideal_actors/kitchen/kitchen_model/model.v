module kitchen_model

import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.common

pub struct Kitchen {
	KitchenCore
}

pub struct KitchenCore {
pub mut:
	name             string
	access_levels    map[string][]string // map[access_level][]user_id
	storage_id       string
	products         []product.Product
	ingredients      []product.Product
	telegram_channel string
	orders           []common.Order
}

// +++++++++ CODE GENERATION BEGINS BELOW +++++++++

pub interface IModelKitchen {
	name string
	access_levels string
	storage_id string
	products []product.Product
	ingredients []product.Product
	telegram_channel string
	orders []common.Order
}
