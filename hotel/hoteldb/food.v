module hoteldb

[heap]
pub struct Food{
pub mut:
	id string
	name string
	url string
	description string
	price string
	state ProductState	
}
