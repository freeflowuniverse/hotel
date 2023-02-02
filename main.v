module main

import freeflowuniverse.hotel.telegram_bot

import os

const (
	memdb_add_path = os.dir(@FILE) + '/data/data_add'
	memdb_source_path = os.dir(@FILE) + '/data/data_main/'
)

fn do() ! {
	// spawn telegram_bot.running_display()
	
	bot_token := get_env_token('BOT_TOKEN') or {panic("Failed to get bot token: $err")}
	mut bot := telegram_bot.new_bot(bot_token, 'Jungle Paradise', memdb_source_path) or {panic("Failed to create new bot: $err")}

	// bot.hotel.add_md_data(memdb_add_path) or {panic("Failed to add data from md files: $err")}

	// println(bot.hotel)

	bot.launch_bot()!
}

fn main(){
	do() or {panic(err)}
}

pub fn get_env_token(token_name string) !string {
	env_secrets := os.read_lines("${os.dir(@FILE)}/.env")!
	for env_secret in env_secrets {
		if env_secret.split('"')[0].trim_string_right("=") == token_name {
			return env_secret.split('"')[1]
		}
	}
	return error("Failed to find $token_name in .env")
}
