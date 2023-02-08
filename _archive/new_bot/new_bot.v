module new_bot

import freeflowuniverse.hotel.hotel
import freeflowuniverse.hotel.hotel.hoteldb
import dariotarantini.vgram

import json
import time

struct TBot {
mut:
	bot vgram.Bot
	flows map[string]Flow // where string is chat_id
	output_channel chan Output
	receiving_channel chan string
	hotel hotel.Hotel
	current_chat_id string
}

type Flow = RegisterFlow

struct RegisterFlow {
mut:
	guest hoteldb.Guest
	username string
	chat_id string
	input_channel chan Input
	output_channel chan Output
	channel Channel
}

struct Input {
mut:
	text string
	success bool=true
	error MessagingError
	channel Channel
}

struct Output {
mut:
	text string
	channel Channel
}

enum Channel {
	telegram_bot
}

struct MessagingError {
Error 
mut:
	error_type ErrorType
}

enum ErrorType {
	success
	timeout
	session_closed
	invalid_input
	other
}

pub fn new_bot (bot_token string, hotel_name string, hotel_db_path_string string) !TBot {
	return TBot{
		bot: vgram.new_bot(bot_token)
		hotel: hotel.new(hotel_name, hotel_db_path_string)!
	}
}

// todo an exit from the program
fn (tbot TBot) send (msg string) {
	_ := tbot.bot.send_message(
		chat_id: tbot.current_chat_id,
		text: msg,
		parse_mode:'MarkdownV2'
	)
}

pub fn (mut bot TBot) get_telegram_updates () {
	mut last_offset := 1
	mut updates := bot.bot.get_updates(timeout: 0, allowed_updates: json.encode(["message"]), offset: last_offset, limit: 100)
	for update in updates {
		if last_offset < update.update_id {
			last_offset = update.update_id
		}
	}
	for {
		select {
			output := <- bot.output_channel {
				bot.send(output.text)
			}
			else {
				bot.new_user_messages(last_offset)
			}
		}

	}
}

fn (mut bot TBot) new_user_messages (last_offset_ int) {
	mut last_offset := last_offset_
	updates := bot.bot.get_updates(timeout: 0, allowed_updates: json.encode(["message"]), offset: last_offset, limit: 100)
	for update in updates {
		if last_offset < update.update_id {
			last_offset = update.update_id
			if update.message.from.id.str() in bot.flows.keys() && update.message.text[0].ascii_str() != '/' {
				bot.current_chat_id = update.message.from.id.str()
				bot.flows[update.message.from.id.str()].input_channel <- Input{
					text: update.message.text
				}
			} else {
				bot.parse_non_flow(update)
			}
		}
	}
}

fn (mut bot TBot) parse_non_flow (update vgram.Update) {
	// todo authentication
	bot.flows.delete(update.message.from.id.str())
	match update.message.text  {
		'/register' {
			mut register_flow := RegisterFlow{
				username: update.message.from.username
				chat_id: update.message.from.id.str()
				output_channel: bot.output_channel
			}
			mut flow_ref := &register_flow
			spawn flow_ref.run() 
			bot.flows[update.message.from.id.str()] = register_flow
			bot.current_chat_id = update.message.from.id.str()
			} 
		else {
			bot.send("Command not recognised, please send '/help' to get more information")
			}
		// '/order' {spawn(new_order_flow(update.username, &output_channel))}
	}
}

fn (mut register_flow RegisterFlow) run () {

	register_flow.guest.hotel_resident = register_flow.ask_yes_no("Is the guest staying at the hotel?", 3600, true) or {panic(err)}
	
	register_flow.guest.firstname = register_flow.ask_string("What is the guest's firstname?", 3600, true) or {panic(err)}
	register_flow.guest.lastname = register_flow.ask_string("What is the guest's firstname?", 3600, true) or {panic(err)}
	
	email := register_flow.ask_yes_no("Would you like to enter an email for the guest?", 3600, true) or {panic(err)}
	if email == true {
		register_flow.guest.email = register_flow.ask_email("What is the guest's email address?", 3600, true) or {panic(err)}
	}	

	telegram := register_flow.ask_yes_no("Would you like to enter a telegram username for the guest?", 3600, true) or {panic(err)}
	if telegram == true {
		register_flow.guest.telegram_username = register_flow.ask_string("What is the guest's telegram username?", 3600, true) or {panic(err)}
	}	

	// log to the db

	println(register_flow.guest)
}

fn (flow RegisterFlow) ask_yes_no(question string, timeout int, repeat bool) !bool {
	flow.output_channel <- Output{
		text: question
	}
	select {
		input := <- flow.input_channel {
			if input.success != true {
				return input.error
			} else if input.text.to_lower() in ['yes', 'y', 'yh', '1'] {
				return true
			} else {
				return false
			}
		}
		timeout * time.second {
			flow.output_channel <- Output{
				text: "Your session has timed out, please start again"
			}
			return MessagingError{error_type: .timeout}
		}
	}
}

fn (flow RegisterFlow) ask_email (question string, timeout int, repeat bool) !string {
	email := flow.ask_string(question, timeout, true)
	if '@' in email.split('') {
		if '.' in email.split('@')[0].split('') {
			return email
		}
	}
	if repeat == true {
		flow.ask_email(question, timeout, repeat)
	} else {
		return MessagingError{error_type: .invalid_input}
	}
	
}

fn (flow RegisterFlow) ask_string (question string, timeout int, repeat bool) !string {
	flow.output_channel <- question
	select {
		input := <- flow.input_channel {
			if input.success != true {
				return input.error
			} else {
				return input.text
			}
		}
		timeout * time.second {
			flow.output_channel <- Output{
				text: "Your session has timed out, please start again"
				}
			return MessagingError{error_type: .timeout}
		}
	}
}



// todo 
// create different flows using this interface
// interface IFlow {

// }