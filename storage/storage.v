module storage

import library

struct Storage {
	id string
	name string
	supplies []ProductAmount
	inventory_checks []InventoryCheck
	serve_order  []ServeOrder
	delivery_order []DeliveryOrder
}

struct Product {
	id string
	name string
	safe_minimum Amount
	maximum Amount
}

struct ProductAmount {
	product  Product
	amount   Amount
}

struct Amount {
	number  int
	unit    Unit
}

enum Unit {
	ml
	grams
	units
	cups
	tsp
	tbsp
}

struct ServeOrder {
	id string
	purpose   string
	product_amount ProductAmount
	destination  string
}

struct DeliveryOrder {
	id string
	product_amount ProductAmount
	description string
}

struct ExternalPayment {
	subject string
	amount library.Price
	description string
	bank_details string // TODO make this better
}

struct InventoryCheck {
	product_amounts []ProductAmount
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
fn (storage Storage) serve_from_storage (order DeliveryOrder) ! {}

// order product delivery
// tells a storage person to order more of a certain product
// needs to call accounting.transfer_funds_from_hotel() 
// TO USER
fn (storage Storage) order_product_delivery (product_amount ProductAmount) ! {}

// log product delivery
// register an incoming delivery of products to the supply
// FROM USER
// ? can this also take DeliveryOrder as an input
fn (storage Storage) log_product_delivery () ! {}

// set safe minimum
// allows the supply manager to set a reasonable lower limit for product store
// FROM USER
fn (storage Storage) set_safe_minimum (product_amount ProductAmount) ! {}

// send external payment request
// sends a request to the accountant to transfer funds to an external party
// INTERNAL
// TODO decide args
fn (storage Storage) send_external_payment_request () ! {}

