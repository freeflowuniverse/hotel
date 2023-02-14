module kitchen

import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.common


// todo clarify how non-base products ie dishes are stored when leftover etx

struct Kitchen {
	id string
	storage_id  string // The idea here is to have your menu defined by contents of supply
	products     []product.Product
	ingredients  []product.Product
}


// Expose Order
// takes in an order (digitally from guest or from employee) and prompts employees to prepare and serve a drink
// TO USER
fn (mut kitchen Kitchen) expose_order (order common.Order) ! {}

// Confirm order completion
// FROM USER
fn (mut kitchen Kitchen) confirm_order_completion (order common.Order) ! {}

// Log product consumption
// informs storage that certain ProductAmounts have been consumed
// INTERNAL
fn (mut kitchen Kitchen) log_product_consumption () ! {}

// Charge guest
// after an order is received this is sent to the guest reducing their funds
// INTERNAL
fn (mut kitchen Kitchen) charge_guest (transaction common.Transaction) ! {}

// Send funds to accountant
// sends the funds from an order directly to the accountant
// INTERNAL
fn (mut kitchen Kitchen) send_funds_to_accountant (transaction common.Transaction) ! {}

// Add product
// can be used to add both ingredients and drinks
// FROM USER
fn (mut kitchen Kitchen) add_product () ! {}

// Expose production requestion
// todo Should this be logged?
// TO USER
fn (mut kitchen Kitchen) expose_production_request () ! {}

// Log production
// log the creation of a certain complex product through consumption of base products
// this might be used when making something to be frozen and used in the future
// FROM USER
fn (mut kitchen Kitchen) log_production () ! {}

