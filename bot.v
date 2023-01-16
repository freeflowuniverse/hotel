module main

import hotel	
import os
import dariotarantini.vgram

// const token="5814239636:AAH1G-yI0Xr7AGi60di8-RtPNXH9vRmAQPQ" // Kristof token
const token = "5971743256:AAGLiLi8zrvW2D6--zt-t7xY0PC7Ee9hrqk" // Jonathan token
const datapath = os.dir(@FILE) + '/data/products'

// TODO make a pub struct VBot with bot, order, hotel attributes

pub struct Order {
pub mut:
	ordering    bool=false
	product_id  string
	quantity    string
}

fn do() ! {

	mut hotel := hotel.new('Jungle Paradise')
	hotel.generate_db(datapath) or {return error("Failed to generate db for hotel: \n$err")}

	hotel.db.log_purchase(
		customer_id : '1'
		product_id : 'B01'
		quantity: '3'
	)!
	
	bot := vgram.new_bot(token)
	// bot.send_message(chat_id: "jungle_paradise_bot",text: 'yo! Made using vgram!')
	mut updates := []vgram.Update{}
	mut last_offset := 0
	mut order := Order{}
	for {
		// TODO some mechanism to delete updates at end of queue
		updates = bot.get_updates(offset: last_offset, limit: 100, timeout: 0, allowed_updates: "message")
		for update in updates {
			if last_offset < update.update_id {
				last_offset = update.update_id
				if order.ordering == true {
					if update.message.text in ["y", "Y", "yes", "Yes"] {
						hotel.db.log_purchase(
							customer_id : hotel.db.get_customer_by_username(update.message.from.username)!.id
							product_id : order.product_id
							quantity: order.quantity
						)!

						order.ordering = false
					}
				} else {
					if update.message.text == "/start" || update.message.text == "/help" {
						bot.send_message(
							chat_id: update.message.from.id.str(),
							text: "Welcome to the Jungle Paradise Ordering Bot\! \n
If you would like to order please type '/order', then the product code and the quantity, each separated by a single space\. \n
An example is given on the following line:
/order B01 2",
							parse_mode:'MarkdownV2'
						)		
					} else if update.message.text.split(' ')[0] == "/order" {
						mut order_msg := update.message.text.split(' ')

						order.ordering = true
						order.product_id = order_msg[1]
						order.quantity = order_msg[2]

						bot.send_message(
							chat_id: update.message.from.id.str(),
							text: "You have submitted an order for ${order.quantity} units of ${hotel.db.get_product(order.product_id)!.name}\.\n
Please confirm by sending a single uncapitalized 'y', cancel by sending any other message\.",
							parse_mode:'MarkdownV2'
						)
					} 
					else if update.message.text == "/menu" {
						bot.send_message(
							chat_id: update.message.from.id.str(),
							text: "**Jungle Paradise Menu** \n\n\n${hotel.db.list_food()} \n$hotel.db.list_beverages() \n",
							parse_mode:'MarkdownV2'
						)
					} 
					else if update.message.text == "/drinks" {
						bot.send_message(
							chat_id: update.message.from.id.str(),
							text: "**Jungle Paradise Drinks Menu** \n\n\n${hotel.db.list_beverages()} \n",
							parse_mode:'MarkdownV2'
						)
					} 
					else if update.message.text == "/food" {
						bot.send_message(
							chat_id: update.message.from.id.str(),
							text: "**Jungle Paradise Food Menu** \n\n\n$hotel.db.list_food() \n",
							parse_mode:'MarkdownV2'
						)
					} 
					
					else {
						bot.send_message(
							chat_id: update.message.from.id.str(),
							text: "
								Please input '/help' to get an introduction to Jungle Paradise's Ordering Bot
							",
							parse_mode:'MarkdownV2'
						)
					}

				}
			}
		}
	}
	println("end")
}


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
//}


fn main(){
	do() or {panic(err)}
}