module interface

import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.hotel.hoteldb

import time

pub struct Actor {
	flows []Flow
}

pub struct Flow {
	ui ui.UserInterface
	user_id string
}



pub fn (mut actor Actor) register_guest_flow () {

	if hotel.db.employee_exists(flow.user_id) == false { // !
		// todo send message stating that they are not allowed to access this command
		return
	}

	mut guest := hoteldb.Guest

	guest.firstname = actor.flow.ui.ask_string(
		question: "What is the guest's firstname?"
		)
	guest.lastname = actor.flow.ui.ask_string(
		question: "What is the guest's lastname?"
		)
	guest.email = actor.flow.ui.ask_string( // ? Should this be ask_email?
		question: "What is the guest's email?"
		validation: validate_email
	) 
	guest.hotel_resident = actor.flow.ui.ask_yesno(
		question: "Is the guest a resident of the hotel?"
	)
	telegram_bool = actor.flow.ui.ask_yesno(
		question: "would you like to register a telegram username with this guest?"
	)
	if telegram_bool {
		guest.telegram_username = actor.flow.ui.ask_string(
			question: "What is the guest's telegram username?"
		)
	}
	// ! hotel.db.add_guest(guest)
}




// for now it seems difficult to modify a product order
// it seems better to simply cancel an order and then resubmit, you will still need to go through the paces anyway.
pub fn (mut actor Actor) order_product_flow () {

	mut order := hoteldb.Order{}

	order.guest_code = //! hotel.db.get_code_from_telegram(flow.user_id)
	employee := // ! hotel.db.get_employee_by_telegram() 

	if employee.id != '' {
		order.employee_id = employee.id

		order.guest_code = actor.flow.ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: actor.flow.ui.validate_guest_code // ! from where
		)
	} else if order.guest_code == '' {
		// todo send message to user saying they are not recognised
	}

	fn (ui UserInterace) validate_guest_code (code string) bool {
		response := ui.client.schedule_job_wait(job.args)
	}
 
	mut another_product := true

	for another_product {

		mut product_order := hoteldb.ProductOrder{}

		product_order.product_code = actor.flow.ui.ask_string(
			question: "What is the product code?"
			validation: validate_product_code
		)

		product := // ! hotel.db.get_product(product_order.product_code)
		product_order.price = product.price

		if product.variable {

			variable_price_bool := actor.flow.ui.ask_yesno("This product is of variable price, would you like to enter a custom price?")

			if variable_price_bool {
				product_order.price = actor.flow.ui.ask_string(
				question: "What variable price would you like to enter?"
				validation: validate_price
				)
			}
		}

		product_order.quantity = actor.flow.ui.ask_int(
			question: "What quantity of this product do you want?"
			validation: validate_quantity
		)

		note_bool := actor.flow.ui.ask_yesno("Would you like to enter a note with this product?")
		
		if note_bool {
			product_order.note = actor.flow.ui.ask_string(
				question: "What note would you like to enter?"
			)
		}

		order << product_order

		another_product = actor.flow.ui.ask_yesno(
			question: "Would you like to add another product?"
		)
	}

	order.order_time = time.now()

	// ! hotel.db.add_order(order)
}




pub fn (mut flow HotelFlow) take_payment () {

	if hotel.db.employee_exists(flow.user_id) == false { // !
		// todo send message stating that they are not allowed to access this command
		return
	}

	mut payment := hoteldb.Payment{}

	payment.guest_code = actor.flow.ui.ask_string(
		question: "What is the guest's four letter code?"
		validation: validate_guest_code
	)

	payment.amount = actor.flow.ui.ask_string(
		question: "What amount is the guest's payment?"
		validation: validate_price
		)

	payment.medium = match actor.flow.ui.ask_dropdown( // ? Should this be ask_email?
		question: "Through what medium is the guest making the payment?"
		items: ['cash', 'card', 'coupon']
	) {
		1 {hoteldb.Medium.cash}
		2 {hoteldb.Medium.card}
		3 {hoteldb.Medium.coupon}
	}

	payment.time_of = time.now()

	// ! hotel.db.add_payment(payment)
}


pub fn (mut flow HotelFlow) get_code () {

	mut guest_code := get_code_from_telegram(flow.user_id)
	employee := // ! hotel.db.get_employee_by_telegram() 

	if employee.id == '' && guest_code == '' {
		// todo send message saying invalid user
		return
	}

	if guest_code == '' {
		mut guest := hoteldb.Guest{}

		guest.firstname = actor.flow.ui.ask_string(
			question: "What is the guest's firstname?"
			)
		guest.lastname = actor.flow.ui.ask_string(
			question: "What is the guest's lastname?"
			)
		guest.email = actor.flow.ui.ask_string( // ? Should this be ask_email?
			question: "What is the guest's email?"
			validation: common.validate_email
		) 

		guest_code = // ! hotel.db.get_guest_code(guest)
	}

	if guest_code == '' {
		// todo send message to guest stating invalid inputs
	} else {
		// todo send message to guest with guest code
	}
}


// Commands:
// **/help** : See this message again
// **/order** : Add products to your basket
// **/register** : Register a new guest
// **/payment** : Allow an employee to register a guest's payment to the hotel
// **/code** : Get a guest's code by email
// **/outstanding** : View a guest's outstanding balance
// **/open** : View open orders
// **/close** : Close a specific order

// **Order Details:**
// If you would like to order please send '/order',then send a message with the following format:
//     _/order GUESTCODE PRODUCT_CODE:QUANTITY:NOTE\\* PRODUCT_CODE:QUANTITY \\.\\.\\._

// An example is given on the following line:
//     _/order CJG:2 BJI:4_

// This is an order for two bottles of water and four chicken curries

// You can optionally add a note to the order like so:
//     _/order CJG:4:'With chapati not rice'_

// However the note must be in single quotation marks

// **Register Details:**

// If you would like to register a new guest, send a message with the following format:
//     _'/register hotel\\* FIRSTNAME LASTNAME EMAIL\\* TELEGRAM\\*'_

// Here are several examples:
//     _'/register hotel John Smith johnsmith@gmail\\.com johnsmith'_
//     _'/register John Smith johnsmith@gmail\\.com'_

// Alternatively, by sending just '/register', you can enter the registration wizard.

// **Payment Details:**

// If you would like to get the code of a certain guest, send a message with the following format:
//     _'/payment GUESTCODE AMOUNT CARD/CASH/COUPON'_

// An example is given on the following line:
//     _'/payment DJWH 40USD CASH'_

// **Code Details:**

// If you would like to get the code of a certain guest, send a message with the following format:
//     _'/code GUESTEMAIL'_

// An example is given on the following line:
//     _'/code johnsmith@gmail\\.com'_

// **Outstanding Details:**

// If you would like to view a guest's outstanding balance, send a message with the following format:
//     _'/outstanding GUESTCODE'_


// **Open Details:**

// If you would like to see all open orders, send the following message:
//     _'/open'_

// **Close Details:**

// If you would like to close an order, send a message with the following format:
//     _'/close ID'_
