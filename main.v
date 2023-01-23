module main

import telegram_bot
import hotel

import os

const (
	memdb_add_path = os.dir(@FILE) + '/data/data_add'
	memdb_source_path = os.dir(@FILE) + '/data/db.json'
)

fn do() ! {
	// env_secrets := os.read_lines("${os.dir(@FILE)}/.env")!
	bot_token := get_env_token('BOT_TOKEN') or {panic("Failed to get bot token: $err")}

	spawn telegram_bot.running_display()
	// server.environment()!
	// mut bot := telegram_bot.new_bot(bot_token)
	// bot.clear_updates()
	// bot.launch_bot()!
	mut h := hotel.new('Jungle Paradise', bot_token, memdb_source_path) or {panic("Failed to create new hotel: $err")}

	h.add_md_data(memdb_add_path) or {panic("Failed to add data from md files: $err")}

	println(h)
}

fn main(){
	do() or {panic(err)}
}

pub fn get_env_token(token_name string) !string {
	env_secrets := os.read_lines("${os.dir(@FILE)}/.env")!
	// println(env_secrets)
	// println("")
	// token_phrase := env_secrets[0].split('"')[1]
	// println(token_phrase)
	// println("")
	for env_secret in env_secrets {
		if env_secret.split('"')[0].trim_string_right("=") == token_name {
			return env_secret.split('"')[1]
		}
	}
	return error("Failed to find $token_name in .env")
}
