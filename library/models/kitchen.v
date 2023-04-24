module models

import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.common

pub struct Kitchen {
KitchenCore
}

pub struct KitchenCore {
// ! These fields need to be copied across to the IKitchen interface every time it is updated! 
// TODO Do code generation check to make sure this and the other one are consistent
pub mut:
	name string
	access_levels map[string][]string // map[access_level][]user_id
	storage_id string
	products []product.Product
	ingredients []product.Product
	telegram_channel string
	orders []common.Order
}