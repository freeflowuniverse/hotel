module telegram_bot

import dariotarantini.vgram
import term
import time
import json
import freeflowuniverse.hotel.hotel
import freeflowuniverse.hotel.hotel.hoteldb

pub struct TelegramBot {
pub mut:
	bot 	      vgram.Bot
	hotel    hotel.Hotel
	sessions map[string]Session // string is username
	current_user string //username
	chat_id string
}

struct Session {
pub mut:
	username string
	order hoteldb.Order
	start_date time.Time // so that old sessions can be deleted
	confirmation bool
	user_status hoteldb.PersonStatus
}


pub fn new_bot (bot_token string, hotel_name string, hotel_db_path_string string) !TelegramBot {
	return TelegramBot{
		bot: vgram.new_bot(bot_token)
		hotel: hotel.new(hotel_name, hotel_db_path_string)!
	}
}

// pub fn (mut bot TelegramBot) clear_updates () {
// 	updates := bot.bot.get_updates(offset: 100)
// }

pub fn (mut bot TelegramBot) launch_bot () ! {
	// spawn running_display()
	mut updates := []vgram.Update{}
	mut last_offset := 0
	for {
		updates = bot.bot.get_updates(timeout: 0, allowed_updates: json.encode(["message", "poll_answer"]), offset: last_offset, limit: 100)
		for update in updates {
			if last_offset < update.update_id {
                last_offset = update.update_id
				bot.parse_cli_update(update)
			}
		}
	}
}


pub fn running_display () {
	for true {
		for i in ['', '.', '..', '...'] {
			println("Bot is running$i")
			time.sleep(200000000)
			term.clear_previous_line()
		}
	}
}



