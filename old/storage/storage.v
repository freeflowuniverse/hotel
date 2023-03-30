module storage

import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.common

import time

struct Storage {
	id string
	name string
	supplies []product.ProductAmount
	inventory_checks []InventoryCheck
	serve_order  []ServeOrder
	delivery_order []DeliveryOrder
}

struct ProductSupply{
product.ProductAmount
mut:
	safe_minimum string //quantity
	maximum string
}


struct InventoryCheck {
	product_amounts []product.ProductAmount
	date    time.Time
	employee_id  string
}

// inventory storage
// prompts store manager to check that inventory matches up with online version
// TO USER
fn (storage Storage) inventory_storage () ! {}

// check if below safe
// called every time any product amount is removed from storage
// INTERNAL
fn (storage Storage) check_if_below_safe (product_id string) ! {}

// serve from storage
// delivers a certain amount of a product to a destination
// TO USER
// ? should this take DeliveryOrder as input or individual params
fn (storage Storage) expose_product_serve (order common.Order) ! {}

// order product delivery
// tells a storage person to order more of a certain product
// needs to call accounting.transfer_funds_from_hotel() 
// INTERNAL
fn (storage Storage) order_product_delivery (order common.Order) ! {}

// log product delivery
// register an incoming delivery of products to the supply
// FROM USER
// ? can this also take DeliveryOrder as an input
fn (storage Storage) confirm_product_delivery () ! {}

// log product serve
// register an incoming delivery of products to the supply
// FROM USER
// ? can this also take DeliveryOrder as an input
fn (storage Storage) confirm_product_serve () ! {}


// set safe minimum
// allows the supply manager to set a reasonable lower limit for product store
// FROM USER
fn (storage Storage) set_safe_minimum (product_amounts []product.ProductAmount) ! {}

// set safe minimum
// allows the supply manager to set a reasonable lower limit for product store
// FROM USER
fn (storage Storage) set_safe_minimum (product_amounts []product.ProductAmount) ! {}

// send external payment request
// sends a request to the accountant to transfer funds to an external party
// INTERNAL
// TODO decide args
fn (storage Storage) send_external_payment_request () ! {}

