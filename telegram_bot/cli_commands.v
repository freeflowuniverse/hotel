module telegram_bot

import dariotarantini.vgram
import time
import freeflowuniverse.hotel.hotel.hoteldb

struct Command {
pub mut:
	keyword string
	args []string
}

// todo add a new command: close order
// todo make two separate help commands
// todo if a payment command has no currency, then this needs to be returned as error
// todo if multiple commands in order return error message

// TODOS 
// todo kitchen should get notified of a new order immediately
// todo add cancel order feature

fn (mut bot TelegramBot) parse_cli_update(update vgram.Update) {

	mut text := update.message.text

	mut username := update.message.from.username
	bot.current_user = username
	bot.chat_id = update.message.from.id.str()
	bot.check_sessions(username)
	if bot.sessions[username].confirmation == true {
		if text in ['y', 'Y', 'yes', 'Yes', 'yh', '1', 'one'] {
			bot.hotel.db.input_order(mut bot.sessions[bot.current_user].order) or {
				_ := bot.bot.send_message(
					chat_id: bot.chat_id,
					text: "Your order has failed, please try again later",
					parse_mode:'MarkdownV2'
				)
				println("ERROR User: $bot.current_user - Failed to confirm order with error: $err")
				return
			} 
			bot.hotel.set_db() or {
				println("SYSTEM FAILURE - Failed to set db")
			}
			_ := bot.bot.send_message(
				chat_id: bot.chat_id,
				text: "We have succesfully placed your order",
				parse_mode:'MarkdownV2'
			)
			println("User: $bot.current_user - Succesfully confirmed order")
			// println("Order: $bot.sessions[bot.current_user].order")
			return
		} 
		bot.sessions[username].confirmation = false
	}	

	if text.len == 0 {
		bot.other_command()
	}

	parts := text.trim_string_left('/').split(' ')
	mut command := Command{
		keyword: parts[0]
	}
	if parts.len > 1 {
		command.args = parts[1..parts.len]
	}

	command.args.filter(it=='')

	match command.keyword {
		'start', 'help' {bot.help_command()}
		'order' {bot.order_command(mut command)} 
		'register' {bot.register_command(mut command)}
		'payment' {bot.payment_command(mut command)}
		'code' {bot.get_code_command(command)}
		'outstanding' {bot.outstanding_command(command)}
		'open' {bot.open_command(command)}
		'close' {bot.close_command(command)}
		else {bot.other_command()}
	}
}

fn (mut bot TelegramBot) check_sessions (username string) {
	if username !in bot.sessions.keys() {
		user_status := bot.hotel.db.get_user_status(username)
		if user_status == hoteldb.PersonStatus.unknown {
			_ := bot.bot.send_message(
					chat_id: bot.chat_id,
					text: "Please register with an employee to be able to access the Jungle Paradise telegram bot",
					parse_mode:'MarkdownV2'
				)
			println("ERROR User: $bot.current_user - Unregistered user attempted to access bot")
			return
		}
		bot.sessions[username] = Session{
			username : username
			start_date : time.now()
			user_status: user_status
		}
	}
}

// Prints out help message
fn (bot TelegramBot) help_command () {
	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: "**Welcome to the Jungle Paradise Ordering Bot**

Commands:
**/help** : See this message again
**/order** : Add products to your basket
**/register** : Register a new guest
**/payment** : Allow an employee to register a guest's payment to the hotel
**/code** : Get a guest's code by email
**/outstanding** : View a guest's outstanding balance
**/open** : View open orders
**/close** : Close a specific order

**Order Details:**
If you would like to order please send '/order',then send a message with the following format:
    _/order GUESTCODE PRODUCT_CODE:QUANTITY:NOTE\\* PRODUCT_CODE:QUANTITY \\.\\.\\._

An example is given on the following line:
    _/order CJG:2 BJI:4_

This is an order for two bottles of water and four chicken curries

You can optionally add a note to the order like so:
    _/order CJG:4:'With chapati not rice'_

However the note must be in single quotation marks

**Register Details:**

If you would like to register a new guest, send a message with the following format:
    _'/register hotel\\* FIRSTNAME LASTNAME EMAIL\\* TELEGRAM\\*'_

Here are several examples:
    _'/order hotel John Smith johnsmith@gmail\\.com johnsmith'_
    _'/order John Smith johnsmith@gmail\\.com'_

**Payment Details:**

If you would like to get the code of a certain guest, send a message with the following format:
    _'/payment GUESTCODE AMOUNT CARD/CASH/COUPON'_

An example is given on the following line:
    _'/payment DJWH 40USD CASH'_

**Code Details:**

If you would like to get the code of a certain guest, send a message with the following format:
    _'/code GUESTEMAIL'_

An example is given on the following line:
    _'/code johnsmith@gmail\\.com'_

**Outstanding Details:**

If you would like to view a guest's outstanding balance, send a message with the following format:
    _'/outstanding GUESTCODE'_


**Open Details:**

If you would like to see all open orders, send the following message:
    _'/open'_

**Close Details:**

If you would like to close an order, send a message with the following format:
    _'/close ID'_

	",
		parse_mode:'MarkdownV2'
	)		
	println("User: $bot.current_user - Succesfully received help menu")
}

// Adds products to basket
fn (mut bot TelegramBot) order_command (mut command Command) {

	if command.args.len <= 1 {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Please ensure your order is of the form \n'/order GUESTCODE PRODUCTCODE:QUANTITY:'NOTE' '\n or '/order GUESTCODE PRODUCTCODE:QUANTITY '",
			parse_mode:'MarkdownV2'
		)
		println("ERROR User: $bot.current_user - Sent order command with too few args")
		return
	}

	mut errors_text := ''
	// todo ensure that if this is sent by a guest, an error message shouldn't give away code information
	if bot.hotel.db.guest_exists(command.args[0]) == false {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Guest Code could not be found, please ensure it is entered correctly",
			parse_mode:'MarkdownV2'
		)
		println("ERROR User: $bot.current_user - Sent order command with an invalid guest code")
		return
	}

	mut order := hoteldb.Order{
		guest_code: command.args[0]
	}

	command.args.drop(1)

	employee := bot.hotel.db.get_employee_by_telegram(bot.current_user)
	if employee.id != '' {
		order.employee_id = employee.id
	}

	for arg in command.args {
		mut arg_parts := arg.split(':')
		if arg_parts.len == 2 {
			arg_parts << ''
		}
		if bot.hotel.db.product_exists(arg_parts[0]) == false {
			errors_text += "Product code not recognised, please ensure you have entered it correctly in the following command: ${command.keyword}\n"
		} 
		if arg_parts[1].int() <= 0 {
			errors_text += "Quantity not recognised, please ensure you have entered a nondecimalised number greater than 0 in the following command: ${command.keyword}\n"
		} 

		if errors_text == '' {
			product_order := hoteldb.ProductOrder{
				product_code: arg_parts[0]
				quantity: arg_parts[1].int()
				note: arg_parts[2]
			}
			order.product_orders << product_order
		}
	}

	if errors_text != '' {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Your order had the following errors: \n$errors_text",
			parse_mode:'MarkdownV2'
		)
		println("ERROR User: $bot.current_user - Sent order command with the following errors: \n$errors_text")
	} else {
		product_orders := bot.print_product_orders(order) or {
			_ := bot.bot.send_message(
				chat_id: bot.chat_id,
				text: "Failed to get product orders, please try again later",
				parse_mode:'MarkdownV2'
			)
			println("SYSTEM FAILURE: Failed to get product orders from session: $err")
			return
		}
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "The following items have been added to your order \n${product_orders} 
Please confirm your order by sending yes
", 
			parse_mode:'MarkdownV2' 
		)
		println("User: $bot.current_user - Successfuly sent order command")
		bot.sessions[bot.current_user].order = order
		bot.sessions[bot.current_user].confirmation = true
	}
}

fn (bot TelegramBot)print_product_orders(order hoteldb.Order) !string {
	mut text := ''
	for product_order in order.product_orders {
		text += "${bot.hotel.db.get_product(product_order.product_code)!.name} x ${product_order.quantity}\n"
	}
	return text
}

/*
pub struct Guest {
pub mut:
	code              string
	firstname  		  string
	lastname   		  string
	email             string
	wallet            finance.Amount
	telegram_username string
}
*/

fn (mut bot TelegramBot) register_command (mut command Command) {

	if bot.sessions[bot.current_user].user_status != hoteldb.PersonStatus.employee {
		bot.other_command()
	}

	if command.args.len <= 1 {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Please ensure your order is of the form '/order hotel\\* FIRSTNAME LASTNAME EMAIL TELEGRAM\\*'
The starred items are optional",
			parse_mode:'MarkdownV2'
		)
		println("FAILURE User: $bot.current_user - Sent register command with too few args")
		return
	}

	mut hotel_resident := false
	if command.args[0] == 'hotel' {
		hotel_resident = true
		command.args.drop(1)
	}

	mut guest := hoteldb.Guest{
		hotel_resident: hotel_resident
		firstname: command.args[0]
		lastname: command.args[1]
	}

	command.args.drop(2)

	if command.args.len > 0 {
		if command.args[0].contains('@') {
			guest.email = command.args[0]
			command.args.drop(1)
			if command.args.len > 0 {
				guest.telegram_username = command.args[0]
			}
		} else {
			guest.telegram_username = command.args[0]
		}
	}

	guest_code := bot.hotel.db.add_guest(mut guest) or {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Failed to register guest, please try again later",
			parse_mode:'MarkdownV2'
		)
		println("SYSTEM FAILURE: Failed to add guest: $err")
		return
	}
	if guest_code[0].ascii_str() == '!' {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "A guest with that email has already been registered
Please verify their identity, their Guest Code is ${guest_code.all_after('!')} ",
			parse_mode:'MarkdownV2'
		)
		println("User: $bot.current_user - Sent register command with an already existing email")
		return
	}

	bot.hotel.set_db() or {
		println("SYSTEM FAILURE - Failed to set db")
	}

	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: "$guest.firstname $guest.lastname has been registered\n Their Guest Code is $guest_code ",
		parse_mode:'MarkdownV2'
	)
	println("User: $bot.current_user - Successfully registered new guest")
}


fn (mut bot TelegramBot) payment_command (mut command Command) {
	if bot.sessions[bot.current_user].user_status != hoteldb.PersonStatus.employee {
		bot.other_command()
	}

	if command.args.len <= 2 {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Please ensure your order is of the form '/payment GUESTCODE AMOUNT CARD/CASH/COUPON '",
			parse_mode:'MarkdownV2'
		)
		println("FAILURE User: $bot.current_user - Sent payment command with too few args")
		return
	}
	amount := bot.hotel.db.currencies.amount_get(command.args[1]) or {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Please ensure your inputted amount has both a value and currency denomination",
			parse_mode:'MarkdownV2'
		)
		println("FAILURE User: $bot.current_user - Sent payment command with invalid amount and following errors: $err")
		return
		}

	mut medium := hoteldb.Medium.cash

	match command.args[2] {
		'cash', 'CASH', 'Cash', 'dollars', 'Dollars' {medium = hoteldb.Medium.cash}
		'card', 'CARD', 'Card', 'debit', 'credit', 'Debit','Credit' {medium = hoteldb.Medium.card}
		'coupon', 'COUPON', 'Coupon' {medium = hoteldb.Medium.coupon}
		else {
			_ := bot.bot.send_message(
				chat_id: bot.chat_id,
				text: "Input error: please ensure you enter the payment medium as 'card', 'cash' or 'coupon'
				",
				parse_mode:'MarkdownV2'
			)
			println("FAILURE User: $bot.current_user - Sent payment command with invalid medium")
			return
		}
	}
	employee := bot.hotel.db.get_employee_by_telegram(bot.current_user)

	mut payment := hoteldb.Payment{
		employee_id: employee.id
		guest_code: command.args[0]
		amount: amount
		medium: medium
	}

	bot.hotel.db.take_guest_payment(payment) or {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Failure: Failed to register guest payment, please ensure the guest code is correct or try again later
			",
			parse_mode:'MarkdownV2'
		)
		println("SYSTEM ERROR: Failed to take guest payment with error: $err")
		return
	}

	bot.hotel.set_db() or {
		println("SYSTEM FAILURE - Failed to set db")
	}

	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: "Successfully sent payment of ${amount.val.str().replace('.','\\.')}${amount.currency.name}
		",
		parse_mode:'MarkdownV2'
	)
	println("Successfully took guest payment of ${amount.val}${amount.currency.name}")

}

fn (mut bot TelegramBot) get_code_command (command Command) {
	if bot.sessions[bot.current_user].user_status != hoteldb.PersonStatus.employee {
		bot.other_command()
	}

	if command.args.len > 1 {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Please ensure your message is of the form '/code GUESTEMAIL'",
			parse_mode:'MarkdownV2'
		)
		println("FAILURE User: $bot.current_user - Sent code command with too few args")
		return
	}

	guest := bot.hotel.db.get_guest_code(command.args[0]) or {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "The inputted email could not be found in the system, please ensure it is entered correctly",
			parse_mode:'MarkdownV2'
		)
		println("FAILURE User: $bot.current_user - Sent code command with invalid email: $err")
		return
	}

	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: "Guest $guest.firstname $guest.lastname found, their code is $guest.code",
		parse_mode:'MarkdownV2'
	)
	println("User: $bot.current_user - Successfully received code from code command")

}

fn (mut bot TelegramBot) outstanding_command (command Command) {
	if command.args.len < 1 {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Please ensure your order is of the form '/outstanding GUESTCODE'",
			parse_mode:'MarkdownV2'
		)
		println("FAILURE User: $bot.current_user - Sent outstanding command with too few args")
		return
	}

	guest := bot.hotel.db.get_guest(command.args[0]) or {
		if bot.sessions[bot.current_user].user_status == hoteldb.PersonStatus.guest {
			_ := bot.bot.send_message(
				chat_id: bot.chat_id,
				text: "Code error, please ensure you have entered your code correctly",
				parse_mode:'MarkdownV2'
			)
			// println("FAILURE User: $bot.current_user - Sent get guest command with invalid code: $err") // todo
		} else {
			_ := bot.bot.send_message(
				chat_id: bot.chat_id,
				text: "The inputted code could not be found in the system, please ensure it is entered correctly",
				parse_mode:'MarkdownV2'
			)
			println("FAILURE User: $bot.current_user - Sent get guest command with invalid code: $err")
		}
		return
	}
	if bot.sessions[bot.current_user].user_status == hoteldb.PersonStatus.guest {
		if guest.telegram_username != bot.current_user {
			_ := bot.bot.send_message(
				chat_id: bot.chat_id,
				text: "Code error, please ensure you have entered your code correctly",
				parse_mode:'MarkdownV2'
			)
			println("FAILURE User: $bot.current_user - Sent get guest command with invalid code")
			return
		}
	}

	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: "${guest.firstname} ${guest.lastname}'s outstanding balance is ${guest.wallet.val.str().replace('.', '\\.').replace('-', '\\-')} ${guest.wallet.currency.name}",
		parse_mode:'MarkdownV2'
	)
	println("User: $bot.current_user - Succesfully requested outstanding balance")
	return

}

fn (bot TelegramBot) open_command (command Command) {
	if bot.sessions[bot.current_user].user_status != hoteldb.PersonStatus.employee {
		bot.other_command()
	}

	orders := bot.hotel.db.get_open_orders() or {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Failed to view open orders, please try again later",
			parse_mode:'MarkdownV2'
		)
		println("SYSTEM FAILURE User: $bot.current_user - Failure to get open orders")
		return
	}

	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: orders,
		parse_mode:'MarkdownV2'
	)
	println("User: $bot.current_user - Successfully displayed open orders")
	return
}

fn (mut bot TelegramBot) close_command (command Command) {
	if bot.sessions[bot.current_user].user_status != hoteldb.PersonStatus.employee {
		bot.other_command()
	}

	if command.args.len < 1 {
		_ := bot.bot.send_message(
			chat_id: bot.chat_id,
			text: "Please ensure your order is of the form '/close ORDER_ID ORDER_ID ORDER_ID \\.\\.\\.'",
			parse_mode:'MarkdownV2'
		)
		println("FAILURE User: $bot.current_user - Sent close command with too few args")
		return
	}

	for order_id in command.args {
		bot.hotel.db.close_order(order_id) or {
			_ := bot.bot.send_message(
				chat_id: bot.chat_id,
				text: "Order id: $order_id not recognised as an open order",
				parse_mode:'MarkdownV2'
			)
			println("FAILURE User: $bot.current_user - Sent close command with invalid order id")
			return
		}
	}
	bot.hotel.set_db() or {
		println("SYSTEM FAILURE - Failed to set db")
	}

	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: "Orders succesfully closed",
		parse_mode:'MarkdownV2'
	)
	println("User: $bot.current_user - Successfully closed order")
	return
}


// dose not change the state but refers the user to call '/help'
fn (bot TelegramBot) other_command () {
	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: "Please send '/help' to get an introduction to Jungle Paradise's Ordering Bot
		",
		parse_mode:'MarkdownV2'
	)
}


