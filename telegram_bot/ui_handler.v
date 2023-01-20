module telegram_bot

import dariotarantini.vgram
import json

// each function should display a list of options and redirect the user to a new function depending on the response.
// the user should be directed to a function based on their current state
// these functions redirect by modifying state.

// TODO delete past polls after they have been sent

pub fn (mut bot TelegramBot) parse_ui_update (update vgram.Update) {
	state := bot.sessions[bot.current_user].state
	println("State: $state")
	if state.waiting_quantity == true || state.waiting_note == true {
		bot.get_order_parameters(update)
	} else if state.basket {
		if state.product_id != '' {
			if state.arrival {
				bot.basket_item_arrival(state.product_id)
			} else {
				bot.basket_item_response(update)
			}
		} else {
			if state.arrival {
				bot.basket_arrival()
			} else {
				bot.basket_response(update)
			}
		}
	} else if state.product_menu {
		if state.arrival {
			bot.product_menu_arrival(state.product_type.str())
		} else {
			bot.product_menu_response(update)
		}
	} else if state.product_list {
		if state.arrival {
			bot.product_list_arrival(update)
		} else {
			bot.product_list_response(update)
		}
	} else {
		if state.arrival {
			bot.main_menu_arrival()
		} else {
			bot.main_menu_response(update)
		}
	}
}

// TODO
fn (mut bot TelegramBot) main_menu_arrival () {
	mut state := &bot.sessions[bot.current_user].state
	state.product_menu = false
	state.basket = false
	state.product_type = .nothing
	question := "Welcome to the Jungle Paradise Ordering Bot UI, please make your navigation selection below"
	options := ["Restaurant", "Bar", "Hotel", "Dock", "Basket", "Confirm"]
	bot.send_poll(question, options)
	// Options:
	// Dock
	// Hotel
	// Bar
	// Restaurant
}

fn (mut bot TelegramBot) main_menu_response (update vgram.Update) {
	response := update.poll_answer.option_ids[0]
	match response {
		0 {bot.product_menu_arrival('food')}
		1 {bot.product_menu_arrival('drink')}
		2 {bot.product_menu_arrival('room')}
		3 {bot.product_menu_arrival('boat')}
		4 {bot.basket_arrival()}
		5 {bot.confirm_command()}
		else {} // Can never occur
	}
}

// TODO
fn (mut bot TelegramBot) product_menu_arrival (product_type string) {
	mut state := &bot.sessions[bot.current_user].state
	state.product_menu = true
	state.product_list = false
	state.product_type = match product_type {
		'nothing' {.nothing}
		'room' {.room}
		'boat' {.boat}
		'food' {.food}
		'drink' {.drink}
		else {.nothing} // TODO really should do a panic here
	}
	question := "Welcome to the Jungle Paradise ${product_type.capitalize()} selection"

	options := ["View Full Menu", "Order ${product_type}s", "Back"]

	bot.send_poll(question, options)
	// Options:
	// Menu
	// Order
	// Back
}

// TODO
fn (mut bot TelegramBot) product_menu_response (update vgram.Update) {
	response := update.poll_answer.option_ids[0]
	product_type := bot.sessions[bot.current_user].state.product_type
	if response == 0 {
		match product_type {
			.room {bot.rooms_command()}
			.boat {bot.boats_command()}
			.drink {bot.drinks_command()}
			.food {bot.food_command()}
			else {}
		}
		bot.product_menu_arrival("$product_type")
	} else if response == 1 {
		bot.product_list_arrival(update)
	} else {
		bot.main_menu_arrival()
	}
}


// TODO
fn (mut bot TelegramBot) product_list_arrival (update vgram.Update) {
	mut state := &bot.sessions[bot.current_user].state
	state.product_list = true
	state.product_menu = false
	state.product_id = ''
	product_type := bot.sessions[bot.current_user].state.product_type
	question := "Please select the products which you wish to order"
	mut options := ["Back"]
	options << match product_type { // TODO this should be returning a list of names for each type
		.room {bot.get_product_names([])}
		.boat {bot.get_product_names([])}
		.drink {bot.get_product_names([])}
		.food {bot.get_product_names([])}
		else {["PANIC"]}
	}
	if options.len == 1 {
		options << 'IGNORE'
	}
	bot.send_poll(question, options)
}

// TODO
fn (mut bot TelegramBot) product_list_response (update vgram.Update) {
	mut state := &bot.sessions[bot.current_user].state
	product_type := bot.sessions[bot.current_user].state.product_type
	response := update.poll_answer.option_ids[0]
	mut product_ids := match product_type { // TODO this should eventually return a list of names
		.room {bot.get_product_ids([])}
		.boat {bot.get_product_ids([])}
		.drink {bot.get_product_ids([])}
		.food {bot.get_product_ids([])}
		else {["PANIC"]}
	}
	if response == 0 {
		bot.product_menu_arrival("$product_type")
	} else {
		state.product_id = product_ids[response]
		bot.get_order_parameters(update)
	}
}

fn (mut bot TelegramBot) get_order_parameters (update vgram.Update) {
	mut state := &bot.sessions[bot.current_user].state
	mut basket := &bot.sessions[bot.current_user].active_basket
	mut text := update.message.text
	if state.waiting_note == false && state.waiting_quantity == false {
		bot.bot.send_message(
			chat_id: bot.current_user,
			text: "Please send the number of units you would like to purchase",
			parse_mode:'MarkdownV2'
		)
		state.waiting_quantity = true
	} else if state.waiting_note == false {
		if text.int() == 0 {
			bot.bot.send_message(
			chat_id: bot.current_user,
			text: "Please enter a nondecimalized number greater than 0",
			parse_mode:'MarkdownV2'
			)
			state.waiting_quantity = true
		} else {
			if state.product_id in basket.products.keys() {
				basket.products[state.product_id].quantity += text.int()
			} else {
				basket.products[state.product_id] = ProductOrder{
					product_id: state.product_id
					product_type: state.product_type
					quantity: text.int()
				}
			}

			bot.bot.send_message(
				chat_id: bot.current_user,
				text: "Please enter any special requests for the order or if not a single full stop",
				parse_mode:'MarkdownV2'
			)

			state.waiting_note = true
		}
	} else {
		basket.products[state.product_id].note += text
		state.product_id = ''
		state.waiting_note = false
		state.waiting_quantity = false
		state.arrival = true
		bot.product_menu_arrival("$state.product_type")

		println("Products: $basket.products")
	}
}

// TODO
fn (mut bot TelegramBot) basket_arrival () {
	mut state := &bot.sessions[bot.current_user].state
	state.basket = true
	state.product_id = ''
	question := "This is your basket"
	mut options := ["Back"]
	products := bot.sessions[bot.current_user].active_basket.products.clone()
	for _, product in products {
		options << product.product_id
	}
	if options.len == 1 {
		options << 'IGNORE'
	}

	println("Options: $options")

	bot.send_poll(question, options)
	println("BasketArrivalOver")
	// Options:
	// Back
	// Product 1
	// Product 2
	// Product 3
	// ...
}

fn (mut bot TelegramBot) basket_response (update vgram.Update) {
	println("BasketR1")
	response := update.poll_answer.option_ids[0]
	println("BasketR2")
	products := bot.sessions[bot.current_user].active_basket.products.clone()
	mut product_ids := []string{}
	println("BasketR3")
	for _, product in products {
		product_ids << product.product_id
	}
	println("BasketR4")
	if response == 0 {
		bot.main_menu_arrival()
	} else {
		bot.basket_item_arrival(product_ids[response])
	}
}

// TODO
fn (mut bot TelegramBot) basket_item_arrival (product_id string) {
	mut state := &bot.sessions[bot.current_user].state
	state.basket = false
	state.product_id = product_id
	question := "This is your basket"
	mut options := ["Back", "Change Quantity", "Change Date", "Delete"]
	bot.send_poll(question, options)
	bot.sessions[bot.current_user].state.product_id = product_id
	// Options:
	// Change Quantity
	// Change Date
	// Delete
	// Back
}

fn (mut bot TelegramBot) basket_item_response (update vgram.Update) {
	response := update.poll_answer.option_ids[0]
	product_id := bot.sessions[bot.current_user].state.product_id
	
	match response {
		0 {bot.change_quantity()}
		1 {bot.change_date()}
		2 {bot.sessions[bot.current_user].active_basket.products.delete(product_id)}
		3 {bot.basket_arrival()}
		else {} // Can never occur
	}
}

// TODO
fn (bot TelegramBot) change_quantity () {

}

// TODO 
fn (bot TelegramBot) change_date () {
	
}

fn (mut bot TelegramBot) send_poll (question string, options []string) {
	bot.sessions[bot.current_user].state.arrival = false
	println("Poll Sent: $question")
	bot.bot.send_poll(
		chat_id: bot.current_user,
		question: question,
		options: json.encode(options),
		is_anonymous: false,
		allows_multiple_answers: false,
		disable_notification: true,
	)
	println("PollState: ${bot.sessions[bot.current_user].state}")
}