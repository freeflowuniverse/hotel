module hoteldb

[heap]
pub struct HotelDB{
pub mut:
	products []Product
	// customers []Customer
}

pub fn new() HotelDB{
	mut p:= HotelDB{}
	return p
}