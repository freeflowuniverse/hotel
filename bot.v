module main
import hotel.hoteldb	
import os

import dariotarantini.vgram
const token="5814239636:AAH1G-yI0Xr7AGi60di8-RtPNXH9vRmAQPQ"
const datapath = os.dir(@FILE) + '/data/products'

fn do(){


	mut db:=hoteldb.new()
	db.process(datapath)!
	println(db)

	// products.food_add(&p)!

	// println(p)
	//
	//
	// bot := vgram.new_bot(token)
	// // bot.send_message(chat_id: "jungle_paradise_bot",text: 'yo! Made using vgram!')
	// mut updates := []vgram.Update{}
	// mut last_offset := 0
	// for {
	// 	updates = bot.get_updates(offset: last_offset, limit: 100)
	// 	for update in updates {
	// 		if last_offset < update.update_id {
	// 			last_offset = update.update_id
	//
	// 			if update.message.photo.len>0{
	// 				println(update.message.photo)
	// 				last:=update.message.photo.last()
	// 				println(last)
	// 				r:=bot.get_file(file_id:last.file_id)
	// 				println(r)
	// 				println("https://api.telegram.org/file/bot${token}/${r.file_path}")
	//
	// 			}
	// 			if update.message.document.file_id != "" {
	// 				println(update.message.document)
	// 				r:=bot.get_file(file_id:update.message.document.file_id)
	// 				println(r)
	// 				println("https://api.telegram.org/file/bot${token}/${r.file_path}")
	//
	// 			}
	// 			if update.message.text == "/order" {
	// 				bot.send_message(
	// 					chat_id: update.message.from.id.str(),
	// 					text: '
	// 						*Please specify your order*
	//
	// 						\\- [apple big: ap1](https://grammy.dev)
	// 						\\- [banana organic: ba1](https://grammy.dev)
	// 					',
	// 					parse_mode:'MarkdownV2'
	// 				)
	// 			}
	// 			if update.message.text == "/start" {
	// 				bot.send_chat_action(
	// 					chat_id: update.message.from.id.str(),
	// 					action: "typing"
	// 				)
	// 				bot.send_message(
	// 					chat_id: update.message.from.id.str(),
	// 					text: 'Hi man'
	// 				)
	// 			}
	// 		}
	// 	}
	// }
	// println("end")
}

fn main(){
	do() or {panic(err)}
}