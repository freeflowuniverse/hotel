module telegram_bot

import dariotarantini.vgram
import term
import time
import json

pub struct TelegramBot {
pub mut:
	bot 	      vgram.Bot
	sessions      map[string]Session //key is string of user id not username
	current_user  string
}

struct Session {
pub mut:
	user_id       string
    username      string
    start_date    i64 // To be cancelled after a certain amount of time
    active_basket Basket
    past_baskets  []Basket
	state         State
	ui            bool
}

enum ProductType {
	nothing
	boat
	room
	food
	drink
}

struct State {
pub mut:
	product_menu  bool
	product_list  bool
    basket        bool
	product_type  ProductType
    product_id    string
	waiting_quantity  bool // ? rather than having them input a value, we could offer them a short selection
	waiting_note  bool
	arrival       bool = true
}

struct Basket {
pub mut:
    products  map[string]ProductOrder // string is product_id
    date      i64
}

struct ProductOrder {
pub mut:
    product_id string
	product_type ProductType
    quantity int
    note string
    for_time i64
}

pub fn new_bot (token string) TelegramBot {
	return TelegramBot{
		bot: vgram.new_bot(token)
	}
}

pub fn (mut bot TelegramBot) clear_updates () {
	updates := bot.bot.get_updates(offset: 100)
}

pub fn (mut bot TelegramBot) launch_bot () ! {
	println("HERE1")
	// spawn running_display()
	mut updates := []vgram.Update{}
	mut last_offset := 0
	for {
		updates = bot.bot.get_updates(timeout: 0, allowed_updates: json.encode(["message", "poll_answer"]), offset: last_offset)
		println("HERE2")
		if last_offset == 0 {
			mut greatest_id := 0
			for update in updates {
				if update.update_id > greatest_id {
					greatest_id = update.update_id
					println("HERE3")
				}
				
			}
			last_offset = greatest_id + 1
		}
		for update in updates {
			println("HERE4")
			bot.parse_update(update)!
			last_offset += 1
		}
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

fn (mut bot TelegramBot) parse_update (update vgram.Update)! {
	println("HERE5")
	mut user_id_ := update.message.from.id
	if update.message.from.id < update.poll_answer.user.id {
		user_id_ = update.poll_answer.user.id
	}
	user_id := user_id_.str()
	println("USERID: $user_id")
	bot.current_user = user_id

	if user_id !in bot.sessions.keys() {
		println("Not recognised")
		bot.sessions[user_id] = Session{
			user_id : user_id
			username : update.message.from.username
			start_date : time.now().unix_time()
		}
	}
	println("HERE6")

	mut session := bot.sessions[user_id]
	println("HERE7")
	if update.message.text == '' {
		println("HERE8")
		bot.parse_ui_update(update)
	} else if (update.message.text[0].ascii_str() != '/') && (session.ui == true) {
		println("HERE9")
		bot.parse_ui_update(update)
	} else {
		session.ui = false
		bot.parse_cli_update(update)!
	}
}

fn  (bot TelegramBot) stringify (order ProductOrder) string {
	product_name := bot.get_product_name(order.product_id)
	mut text:= "- $product_name x $order.quantity"
	if order.note != '' {
		text += ' (Note: $order.note)'
	}
	return text
}

