module hoteldb


import freeflowuniverse.crystallib.actionparser

pub fn (mut db HotelDB) process(path string)!{

	mut ap:=actionparser.dir_parse(path)!
}