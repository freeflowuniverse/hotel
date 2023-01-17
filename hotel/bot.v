module hotel

import dariotarantini.vgram
import term
import time

pub struct VBot {
pub mut:
	bot 	 vgram.Bot
	orders   map[string]BotOrder //key is string of user id not username
}

pub struct BotOrder {
pub mut:
	product_id   string
	quantity     string
}

pub fn new_bot (token string) VBot {
	return VBot{
		bot: vgram.new_bot(token)
	}
}
fn running_display () {
	for true {
		for i in ['', '.', '..', '...'] {
			println("Bot is running$i")
			time.sleep(200000000)
			term.clear_previous_line()
		}
	}
}

pub fn (mut h Hotel) launch_bot () ! {
	spawn running_display()
	mut updates := []vgram.Update{}
	mut last_offset := 0
	for {
		updates = h.vbot.bot.get_updates(timeout: 0, allowed_updates: "message", offset: last_offset)
		if last_offset == 0 {
			mut greatest_id := 0
			for update in updates {
				if update.update_id > greatest_id {
					greatest_id = update.update_id
				}
				
			}
			last_offset = greatest_id + 1
			// updates = h.vbot.bot.get_updates(timeout: 0, allowed_updates: "message", offset: last_offset)
		}
		for update in updates {
			h.parse_message(update)!
			last_offset += 1
		}
	}
}

fn (mut h Hotel) parse_message (update vgram.Update) ! {
	if update.message.from.id.str() in h.vbot.orders.keys() {
		h.confirm_message(update)!
		h.vbot.orders.delete(update.message.from.id.str())
	} else {
		command := update.message.text.split(' ')[0]
		match command {
			'/start', '/help' {h.help_command(update)}
			'/menu' {h.menu_command(update)}
			'/food' {h.food_command(update)}
			'/drinks' {h.beverages_command(update)}
			'/order' {h.order_command(update)!}
			'/boats' {h.boats_command(update)}
			'/rooms' {h.rooms_command(update)}
			else {h.other_command(update)}
		}
	}
}

fn (h Hotel) confirm_message (update vgram.Update) ! {
	if update.message.text in ["y", "Y", "yes", "Yes"] {

		order := h.vbot.orders[update.message.from.id.str()]
		h.db.log_purchase(
			customer_id : h.db.get_customer_by_username(update.message.from.username)!.id
			product_id : order.product_id
			quantity: order.quantity
		)!
		
		h.vbot.bot.send_message(
			chat_id: update.message.from.id.str(),
			text: "Confirmed: ${order.quantity} units of ${h.db.get_product(order.product_id)!.name}\n",
			parse_mode:'MarkdownV2'
		)
			
	} else {
		h.vbot.bot.send_message(
			chat_id: update.message.from.id.str(),
			text: "Your order has been cancelled, please retry\n",
			parse_mode:'MarkdownV2'
		)
	}
}

fn (h Hotel) help_command (update vgram.Update) {
	h.vbot.bot.send_message(
		chat_id: update.message.from.id.str(),
		text: "**Welcome to the Jungle Paradise Ordering Bot**

Commands:
**/help** : See this message again
**/order** : Submit an order to Jungle Paradise Ordering Bot
**/menu** : View the full Jungle Paradise menu
**/food** : View the Jungle Paradise food menu
**/drinks** : View the Jungle Paradise drinks menu
**/boats** : View the Jungle Paradise's boat availability
**/rooms** : View the Jungle Paradise's room availability

**Order Details:**
If you would like to order please send '/order', then the product code and the quantity, each separated by a single space

An example is given on the following line:
	_/order B01 2_\n",
		parse_mode:'MarkdownV2'
	)		
}

fn (mut h Hotel) order_command (update vgram.Update) ! {

	mut order_components := update.message.text.split(' ')
	mut text := ""
	if order_components.len != 3 {
		text = "Order command not recognised, if you would like to order please send '/order', then the product code and the quantity, each separated by a single space

An example is given on the following line:
	_/order B01 2_\n"
	} else if h.db.check_product_exists(order_components[1]) == false{
		text = "Product code not recognised, please ensure you have entered it correctly"
	} else if order_components[2].int() <= 0 {
		text = "Quantity not recognised, please ensure you have entered a nondecimalised number greater than 0"
	} else {
		order := BotOrder{
			product_id: order_components[1]
			quantity: order_components[2]
		}
		h.vbot.orders[update.message.from.id.str()] = order
		text = "You have submitted an order for ${order.quantity} units of ${h.db.get_product(order.product_id)!.name}\n
Please confirm by sending a single uncapitalized 'y', cancel by sending any other message\n"

	}

	h.vbot.bot.send_message(
		chat_id: update.message.from.id.str(),
		text: text
		parse_mode:'MarkdownV2'
	)

}

fn (h Hotel) menu_command (update vgram.Update) {
	h.vbot.bot.send_message(
		chat_id: update.message.from.id.str(),
		text: "**Jungle Paradise Menu** \n\n${h.db.list_products('Food')} \n${h.db.list_products('Beverage')} \n",
		parse_mode:'MarkdownV2'
	)
}

fn (h Hotel) food_command (update vgram.Update) {
	h.vbot.bot.send_message(
		chat_id: update.message.from.id.str(),
		text: "**Jungle Paradise Food Menu** \n\n${h.db.list_products('Food')} \n",
		parse_mode:'MarkdownV2'
	)
}

fn (h Hotel) beverages_command (update vgram.Update) {
	h.vbot.bot.send_message(
		chat_id: update.message.from.id.str(),
		text: "**Jungle Paradise Drinks Menu** \n\n${h.db.list_products('Beverage')} \n",
		parse_mode:'MarkdownV2'
	)
}

fn (h Hotel) boats_command (update vgram.Update) {
	h.vbot.bot.send_message(
		chat_id: update.message.from.id.str(),
		text: "**Jungle Paradise Boat Selection** \n\n${h.db.list_products('Boat')} \n",
		parse_mode:'MarkdownV2'
	)
}

fn (h Hotel) rooms_command (update vgram.Update) {
	h.vbot.bot.send_message(
		chat_id: update.message.from.id.str(),
		text: "**Jungle Paradise Room Selection** \n\n${h.db.list_products('Room')} \n",
		parse_mode:'MarkdownV2'
	)
}

fn (h Hotel) other_command (update vgram.Update) {
	h.vbot.bot.send_message(
		chat_id: update.message.from.id.str(),
		text: "
			Please send '/help' to get an introduction to Jungle Paradise's Ordering Bot
		",
		parse_mode:'MarkdownV2'
	)
}