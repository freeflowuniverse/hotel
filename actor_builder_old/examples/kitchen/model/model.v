module model

import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.common

pub struct Kitchen {
KitchenCore
}

pub struct BrandKitchen {
KitchenCore
}

pub struct KitchenCore {
pub mut:
	name string
	access_levels map[string][]string // map[access_level][]user_id
	storage_id string
	products []product.Product
	ingredients []product.Product
	telegram_channel string
	orders []common.Order
}