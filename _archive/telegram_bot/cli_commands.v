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
// todo allow employees to login to a customer code

fn (bot TelegramBot) send (msg string) {
	_ := bot.bot.send_message(
		chat_id: bot.chat_id,
		text: msg,
		parse_mode:'MarkdownV2'
	)
}

fn (mut bot TelegramBot) parse_cli_update(update vgram.Update) {

	mut username := update.message.from.username
	bot.current_user = username
	bot.chat_id = update.message.from.id.str()
	bot.check_sessions(username)

	mut text := update.message.text

	if text.len == 0 {
		bot.other_command()
	}

	if text[0].ascii_str() != '/' {
		if bot.sessions[username].order_confirmation == true {
			bot.order_confirmation(text)
		} else if bot.sessions[username].register_guest == true {
			bot.register_command(mut Command{keyword:text}) // todo maybe I need to add args as well
		} else {
			bot.other_command()
		}
		return
	}

	bot.sessions[username].register_guest = false
	bot.sessions[username].order_confirmation = false

	parts := text.trim_string_left('/').split(' ')
	mut command := Command{
		keyword: parts[0]
	}
	if parts.len > 1 {
		command.args = parts[1..parts.len]
	}

	command.args.filter(it=='')
	
	if bot.sessions[bot.current_user].user_status == hoteldb.PersonStatus.employee {
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
	} else {
		match command.keyword {
			'start', 'help' {bot.help_command()}
			'order' {bot.order_command(mut command)} 
			'outstanding' {bot.outstanding_command(command)}
			else {bot.other_command()}
		}
	}
}

fn (mut bot TelegramBot) order_confirmation (text string) {
	if text in ['y', 'Y', 'yes', 'Yes', 'yh', '1', 'one'] {
		bot.hotel.db.input_order(mut bot.sessions[bot.current_user].order) or {
			bot.send("Your order has failed, please try again later")
			println("ERROR User: $bot.current_user - Failed to confirm order with error: $err")
			return
		} 
		bot.hotel.set_db() or {
			println("SYSTEM FAILURE - Failed to set db")
		}
		bot.send("We have succesfully placed your order")
		println("User: $bot.current_user - Succesfully confirmed order")
		return
	} 
	bot.sessions[bot.current_user].order_confirmation = false
}

fn (mut bot TelegramBot) check_sessions (username string) {
	if username !in bot.sessions.keys() {
		user_status := bot.hotel.db.get_user_status(username)
		if user_status == hoteldb.PersonStatus.unknown {
			bot.send("Please register with an employee to be able to access the Jungle Paradise telegram bot")
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
	msg := "**Welcome to the Jungle Paradise Ordering Bot**

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
    _'/register hotel John Smith johnsmith@gmail\\.com johnsmith'_
    _'/register John Smith johnsmith@gmail\\.com'_

Alternatively, by sending just '/register', you can enter the registration wizard.

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

	"
	bot.send(msg)	
	println("User: $bot.current_user - Succesfully received help menu")
}

// Adds products to basket
fn (mut bot TelegramBot) order_command (mut command Command) {

	if command.args.len <= 1 {
		bot.send("Please ensure your order is of the form \n'/order GUESTCODE PRODUCTCODE:QUANTITY:'NOTE' '\n or '/order GUESTCODE PRODUCTCODE:QUANTITY '")
		println("ERROR User: $bot.current_user - Sent order command with too few args")
		return
	}

	mut errors_text := ''
	// todo ensure that if this is sent by a guest, an error message shouldn't give away code information
	if bot.hotel.db.guest_exists(command.args[0]) == false {
		bot.send("Guest Code could not be found, please ensure it is entered correctly")
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
		bot.send("Your order had the following errors: \n$errors_text")
		println("ERROR User: $bot.current_user - Sent order command with the following errors: \n$errors_text")
	} else {
		product_orders := bot.print_product_orders(order) or {
			bot.send("Failed to get product orders, please try again later")
			println("SYSTEM FAILURE: Failed to get product orders from session: $err")
			return
		}
		bot.send("The following items have been added to your order \n${product_orders} \nPlease confirm your order by sending yes\n")
		println("User: $bot.current_user - Successfuly sent order command")
		bot.sessions[bot.current_user].order = order
		bot.sessions[bot.current_user].order_confirmation = true
	}
}

fn (bot TelegramBot)print_product_orders(order hoteldb.Order) !string {
	mut text := ''
	for product_order in order.product_orders {
		text += "${bot.hotel.db.get_product(product_order.product_code)!.name} x ${product_order.quantity}\n"
	}
	return text
}

fn valid_email (email string) bool {
	if '@' in email.split('') {
		if '.' in email.split('@')[1].split('') {
			return true
		}
	}
	return false
}

// register a new guest
fn (mut bot TelegramBot) register_command (mut command Command) {

	mut guest := hoteldb.Guest{}

	// todo check if this is being persisted
	mut session := bot.sessions[bot.current_user]
	if session.register_guest == true {
		if session.new_guest.firstname == '' {
			session.new_guest.firstname = command.keyword
			bot.send("Success, please enter your lastname")
		} else if session.new_guest.lastname == '' {
			session.new_guest.lastname = command.keyword
			bot.send("Success, please enter your email")
		} else if session.new_guest.email == '' {
			if valid_email(command.keyword) {
				session.new_guest.email = command.keyword
				bot.send("Success, is the guest a resident of the hotel? Reply with a 'yes'")
			} else {
				bot.send("Please enter a valid email")
			}
		} else if session.new_guest.resident_checked == false {
			if command.keyword in ['y', 'Y', 'yes', 'Yes', 'yh', '1', 'one'] {
				session.new_guest.hotel_resident = true
			}
			session.new_guest.resident_checked = true
			bot.send("Success, please enter a telegram username or send 'no'")
		} else {
			if command.keyword.to_lower() !in ['no', 'nah', 'n', '0'] {
				session.new_guest.telegram_username = command.keyword
			}
			session.register_guest = false
			guest = hoteldb.Guest{
				firstname: session.new_guest.firstname
				lastname: session.new_guest.lastname
				email: session.new_guest.email
				telegram_username: session.new_guest.telegram_username
				hotel_resident: session.new_guest.hotel_resident
			}
		}
	} else {
		if command.args.len <= 1 {
			bot.send("Not enough args added, register wizard initialized\\. To exit, enter any other command beginning with '/' \nPlease enter your firstname:")
			println("User: $bot.current_user - Sent register command with too few args, register wizard started")
			session.register_guest = true
			return
		}

		mut hotel_resident := false
		if command.args[0] == 'hotel' {
			hotel_resident = true
			command.args.drop(1)
		}

		guest = hoteldb.Guest{
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
	}

	if session.register_guest {
		bot.sessions[bot.current_user] = session
		return
	}

	mut guest_code := ''
	guest_code = bot.hotel.db.add_guest(mut guest) or {
		if err.msg()[0].ascii_str() == '!' {
			bot.send("A guest with that email has already been registered\nPlease verify their identity, their Guest Code is ${guest_code.all_after('!')} ")
			println("User: $bot.current_user - Sent register command with an already existing email")
		} else {
			bot.send("Failed to register guest, please try again later")
			println("SYSTEM FAILURE: Failed to add guest: $err")
		}
		return
	}

	bot.hotel.set_db() or { println("SYSTEM FAILURE - Failed to set db") }
	
	bot.send("$guest.firstname $guest.lastname has been registered\n Their Guest Code is $guest_code ")
	println("User: $bot.current_user - Successfully registered new guest")
}

// submit a guest payment
fn (mut bot TelegramBot) payment_command (mut command Command) {

	if command.args.len <= 2 {
		bot.send("Please ensure your order is of the form '/payment GUESTCODE AMOUNT CARD/CASH/COUPON '")
		println("FAILURE User: $bot.current_user - Sent payment command with too few args")
		return
	}
	amount := bot.hotel.db.currencies.amount_get(command.args[1]) or {
		bot.send("Please ensure your inputted amount has both a value and currency denomination")
		println("FAILURE User: $bot.current_user - Sent payment command with invalid amount and following errors: $err")
		return
		}

	mut medium := hoteldb.Medium.cash

	match command.args[2] {
		'cash', 'CASH', 'Cash', 'dollars', 'Dollars' {medium = hoteldb.Medium.cash}
		'card', 'CARD', 'Card', 'debit', 'credit', 'Debit','Credit' {medium = hoteldb.Medium.card}
		'coupon', 'COUPON', 'Coupon' {medium = hoteldb.Medium.coupon}
		else {
			bot.send("Input error: please ensure you enter the payment medium as 'card', 'cash' or 'coupon'")
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
		bot.send("Failure: Failed to register guest payment, please ensure the guest code is correct or try again later")
		println("SYSTEM ERROR: Failed to take guest payment with error: $err")
		return
	}

	bot.hotel.set_db() or {
		println("SYSTEM FAILURE - Failed to set db")
	}

	bot.send("Successfully sent payment of ${amount.val.str().replace('.','\\.')}${amount.currency.name}")
	println("Successfully took guest payment of ${amount.val}${amount.currency.name}")

}

// get a guests code via their email
fn (mut bot TelegramBot) get_code_command (command Command) {
	
	if command.args.len > 1 {
		bot.send("Please ensure your message is of the form '/code GUESTEMAIL'")
		println("FAILURE User: $bot.current_user - Sent code command with too few args")
		return
	}

	guest := bot.hotel.db.get_guest_code(command.args[0]) or {
		bot.send("The inputted email could not be found in the system, please ensure it is entered correctly")
		println("FAILURE User: $bot.current_user - Sent code command with invalid email: $err")
		return
	}

	bot.send("Guest $guest.firstname $guest.lastname found, their code is $guest.code")
	println("User: $bot.current_user - Successfully received code from code command")

}

// view a guests outstanding balance
fn (mut bot TelegramBot) outstanding_command (command Command) {
	if command.args.len < 1 {
		bot.send("Please ensure your order is of the form '/outstanding GUESTCODE'")
		println("FAILURE User: $bot.current_user - Sent outstanding command with too few args")
		return
	}

	guest := bot.hotel.db.get_guest(command.args[0]) or {
		if bot.sessions[bot.current_user].user_status == hoteldb.PersonStatus.guest {
			bot.send("Code error, please ensure you have entered your code correctly")
			println("FAILURE User: $bot.current_user - Sent get guest command with invalid code: $err") // todo
		} else {
			bot.send("The inputted code could not be found in the system, please ensure it is entered correctly")
			println("FAILURE User: $bot.current_user - Sent get guest command with invalid code: $err")
		}
		return
	}
	if bot.sessions[bot.current_user].user_status == hoteldb.PersonStatus.guest {
		if guest.telegram_username != bot.current_user {
			bot.send("Code error, please ensure you have entered your code correctly")
			println("FAILURE User: $bot.current_user - Sent get guest command with invalid code")
			return
		}
	}

	bot.send("${guest.firstname} ${guest.lastname}'s outstanding balance is ${guest.wallet.val.str().replace('.', '\\.').replace('-', '\\-')} ${guest.wallet.currency.name}")
	println("User: $bot.current_user - Succesfully requested outstanding balance")
	return

}

// view open orders
fn (bot TelegramBot) open_command (command Command) {
	if bot.sessions[bot.current_user].user_status != hoteldb.PersonStatus.employee {
		bot.other_command()
	}

	orders := bot.hotel.db.get_open_orders() or {
		bot.send("Failed to view open orders, please try again later")
		println("SYSTEM FAILURE User: $bot.current_user - Failure to get open orders")
		return
	}

	bot.send(orders)
	println("User: $bot.current_user - Successfully displayed open orders")
	return
}

// close an order
fn (mut bot TelegramBot) close_command (command Command) {
	if bot.sessions[bot.current_user].user_status != hoteldb.PersonStatus.employee {
		bot.other_command()
	}

	if command.args.len < 1 {
		bot.send("Please ensure your order is of the form '/close ORDER_ID ORDER_ID ORDER_ID \\.\\.\\.'")
		println("FAILURE User: $bot.current_user - Sent close command with too few args")
		return
	}

	for order_id in command.args {
		bot.hotel.db.close_order(order_id) or {
			bot.send("Order id: $order_id not recognised as an open order")
			println("FAILURE User: $bot.current_user - Sent close command with invalid order id")
			return
		}
	}
	bot.hotel.set_db() or {
		println("SYSTEM FAILURE - Failed to set db")
	}

	bot.send("Orders succesfully closed")
	println("User: $bot.current_user - Successfully closed order")
	return
}


// dose not change the state but refers the user to call '/help'
fn (bot TelegramBot) other_command () {
	bot.send("Please send '/help' to get an introduction to Jungle Paradise's Ordering Bot")
}






struct TelegramBot {
	bot vgram.Bot
	wizards map[string]thread // where string is username
}

if update.message.text.starts_with('/register') {
	wizard_ch := chan vgram.Update
	bot.wizards[update.message.from.username] = spawn register_wizard(wizard_ch)
}

fn register_wizard() {

}