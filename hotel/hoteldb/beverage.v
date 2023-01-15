module hoteldb

[heap]
pub struct Beverage{
pub mut:
	id string
	name string
	url string
	description string
	price string
	state ProductState	
}
