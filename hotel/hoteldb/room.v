module hoteldb


[heap]
pub struct Room{
pub mut:
	id string
	name string
	url string
	description string
	nr string
	price int   //usd to ... 
	state ProductState	
}