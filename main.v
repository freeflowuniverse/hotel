module main

import telegram_bot
import hotel

import os

const (
	memdb_add_path = os.dir(@FILE) + '/data/data_add'
	memdb_source_path = os.dir(@FILE) + '/data/db.json'
)

fn do() ! {
	env_secrets := os.read_lines("${os.dir(@FILE)}/.env")!
	bot_token := env_secrets[0].split('"')[0]

	// server.environment()!
	// mut bot := telegram_bot.new_bot(bot_token)
	// bot.clear_updates()
	// bot.launch_bot()!
	mut h := hotel.new('Jungle Paradise', bot_token, memdb_source_path) or {return error("Failed to created a new hotel: $err")}
	
	// hotel.generate_db(memdb_source_path) or {return error("Failed to generate db for hotel: \n$err")}
}

fn main(){
	do() or {panic(err)}
}

