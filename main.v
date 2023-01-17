module main

import hotel	
import os

const (
	bot_token = "5971743256:AAGLiLi8zrvW2D6--zt-t7xY0PC7Ee9hrqk"
	memdb_source_path = os.dir(@FILE) + '/data/products'
)

fn do() ! {
	mut hotel := hotel.new('Jungle Paradise', bot_token)
	hotel.generate_db(memdb_source_path) or {return error("Failed to generate db for hotel: \n$err")}
	hotel.launch_bot()!
}

fn main(){
	do() or {panic(err)}
}

