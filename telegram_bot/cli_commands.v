module telegram_bot

import dariotarantini.vgram
import time

// TODO add in for_time to ordered products (maybe only for boat and room)
// TODO also availability for boat and room needs to be displayed

struct Command {
pub mut:
	keyword     string
	args   []string
}

fn (mut bot TelegramBot) parse_cli_update(update vgram.Update) ! {
	/* Possible inputs
	/c dd as
	/c
	/c sadwsd /c asdas
	/c awdas aasca/wdaw
	adwdaw
	awda/wadw
	*/

	mut text := update.message.text

	mut commands := []Command{}
	mut command_strings := text.split('/')
	mut stripped_commands := command_strings[1..command_strings.len]

	for command_string in stripped_commands {
		components := command_string.split(' ')
		
		for component in components {
			component.replace(' ', '')
		}
		components.filter(it=='') // TODO make sure this deletes all empty components from components

		commands << Command{
			keyword: components[0]
			args: components[1..components.len]
		}
	}

	if commands.len == 0 {
		bot.other_command()
	}
	// TODO consider whether recording state changes are necessary
	for command in commands {
		match command.keyword {
			'start', 'help' {bot.help_command()}
			'menu' {bot.menu_command()} 
			'food' {bot.food_command()}
			'drinks' {bot.drinks_command()}
			'order' {bot.order_command(command)!} 
			'boats' {bot.boats_command()} 
			'rooms' {bot.rooms_command()} 
			'basket' {bot.basket_command()} 
			'clear' {bot.clear_command()}
			'confirm' {bot.confirm_command()}
			'ui' {bot.ui_command()}
			else {bot.other_command()}
		}
	}
}

// Prints out help message
fn (bot TelegramBot) help_command () {
	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "**Welcome to the Jungle Paradise Ordering Bot**

Commands:
**/help** : See this message again
**/order** : Add products to your basket
**/menu** : View the full Jungle Paradise menu
**/food** : View the Jungle Paradise food menu
**/drinks** : View the Jungle Paradise drinks menu
**/boats** : View the Jungle Paradise's boat availability
**/rooms** : View the Jungle Paradise's room availability
**/basket** : View your current basket
**/confirm** : Confirm and submit your oder
**/clear** : Clears the current basket
**/ui** : View the Jungle Paradise's room availability

**Order Details:**
If you would like to order please send '/order',then a series of product:quantities separated by single spaces

An example is given on the following line:
	_/order B01:2 F01:4_

This is an order for two bottles of water and four chicken curries

You can optionally add a note to the order like so:
	_/order F01:4:'With chapati not rice' _

However the note must be in single quotation marks
	",
		parse_mode:'MarkdownV2'
	)		
}

// Adds products to basket
fn (mut bot TelegramBot) order_command (command Command) ! {

	mut errors_text := ''
	mut success_products := [][]string{}
	mut basket := &bot.sessions[bot.current_user].active_basket // TODO, make sure I do references everywhere

	for arg in command.args {
		mut arg_parts := arg.split(':')
		if arg_parts.len == 2 {
			arg_parts << ''
		}
		mut error_text := ''
		if bot.product_exists(arg_parts[0]) == false {
			error_text += "Product code not recognised, please ensure you have entered it correctly in the following command: ${command.keyword}\n"
		} 
		if arg_parts[1].int() <= 0 {
			error_text += "Quantity not recognised, please ensure you have entered a nondecimalised number greater than 0 in the following command: ${command.keyword}\n"
		} 
		if error_text == '' {
			order := ProductOrder{
				product_id: arg_parts[0]
				quantity: arg_parts[1].int()
				note: arg_parts[2]
				for_time: time.now().unix_time()
			}

			if order.product_id in basket.products.keys() {
				basket.products[order.product_id].quantity += order.quantity
			} else {
				basket.products[order.product_id] = order
			}
			success_products << [order.product_id, order.quantity.str()]
		}

		errors_text += error_text
	}

	if errors_text != '' {
		bot.bot.send_message(
			chat_id: bot.current_user,
			text: "Your order had the following errors: \n$errors_text",
			parse_mode:'MarkdownV2'
		)
	}

	if success_products.len != 0 {
		bot.bot.send_message(
			chat_id: bot.current_user,
			text: "The following items have been added to your basket \n${print_successes(success_products)}"// ${bot.get_stringified_products(success_products)}",
			parse_mode:'MarkdownV2'
		)
	}
}

fn print_successes(successes [][]string) string {
	mut text := ''
	for success in successes {
		text += "${success[0]} x ${success[1]}\n"
	}
	return text
}

// Displays food and drink options
fn (bot TelegramBot) menu_command () {
	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "**Jungle Paradise Menu** \n\n${bot.get_foods([])} \n${bot.get_drinks([])} \n",
		parse_mode:'MarkdownV2'
	)
}

// Displays food options
fn (bot TelegramBot) food_command () {
	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "**Jungle Paradise Food Menu** \n\n${bot.get_foods([])} \n",
		parse_mode:'MarkdownV2'
	)
}

// Displays drink options
fn (bot TelegramBot) drinks_command () {
	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "**Jungle Paradise Drinks Menu** \n\n${bot.get_drinks([])} \n",
		parse_mode:'MarkdownV2'
	)
}

// Displays boat options
fn (bot TelegramBot) boats_command () {
	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "**Jungle Paradise Boat Selection** \n\n${bot.get_boats([])} \n",
		parse_mode:'MarkdownV2'
	)
}

// Displays room options
fn (bot TelegramBot) rooms_command () {
	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "**Jungle Paradise Room Selection** \n\n${bot.get_rooms([])} \n",
		parse_mode:'MarkdownV2'
	)
}

// Displays the users current basket
fn (bot TelegramBot) basket_command () {
	basket := bot.sessions[bot.current_user].active_basket
	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "The following items are in your basket: ${basket.products.keys()} ", // \n${bot.get_stringified_products(basket.products.keys())}",
		parse_mode:'MarkdownV2'
	)
}

// Clears the basket
fn (mut bot TelegramBot) clear_command () {
	bot.sessions[bot.current_user].active_basket = Basket{}

	bot.sessions[bot.current_user].state.arrival = true

	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "Your basket has been cleared",
		parse_mode:'MarkdownV2'
	)
}

// Confirms the ordering of the basket
fn (mut bot TelegramBot) confirm_command () {
	
	products := bot.sessions[bot.current_user].active_basket.products.clone()
	bot.log_purchases(products.values())

	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "The following items have been ordered: ${products.keys()} ", // \n${bot.get_products(products.keys())}",
		parse_mode:'MarkdownV2'
	)

	bot.clear_command()
}

// Changes the session state to UI mode
fn (mut bot TelegramBot) ui_command () {
	bot.sessions[bot.current_user].ui = true
	bot.main_menu_arrival()
}

// dose not change the state but refers the user to call '/help'
fn (bot TelegramBot) other_command () {
	bot.bot.send_message(
		chat_id: bot.current_user,
		text: "Please send '/help' to get an introduction to Jungle Paradise's Ordering Bot
		",
		parse_mode:'MarkdownV2'
	)
}


