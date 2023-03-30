module bar

import freeflowuniverse.hotel.library.product

// todo lots of actors have extra info such as opening hours notices etc
// todo we need to somehow accomodate for this, maybe with messages?

struct Bar {
	id string
	storage_id   string // The idea here is to have your menu defined by contents of supply
	products     []product.Product
	ingredients  []product.Product
	// todo add opening hours + notices section maybe information/notices map[string]Message where string is topic
}

// Expose Order
// takes in an order (digitally from guest or from employee) and prompts employees to prepare and serve a drink
// TO USER
// fn (bar Bar) expose_order (order common.Order) ! {}

// Confirm order completion
// FROM USER
// fn (mut bar Bar) confirm_order_completion (order common.Order) ! {}

// Log product consumption
// informs storage that certain ProductAmounts have been consumed
// INTERNAL
// fn (bar Bar) log_product_consumption () ! {}

// Charge guest
// after an order is received this is sent to the guest reducing their funds
// INTERNAL
// fn (bar Bar) charge_guest (transaction common.Transaction) ! {}

// Send funds to accountant
// sends the funds from an order directly to the accountant
// INTERNAL
// fn (bar Bar) send_funds_to_accountant (transaction common.Transaction) ! {}

// Add product
// can be used to add both ingredients and drinks
// fn (mut bar Bar) add_product () ! {}