module hoteldb

type Product = Beverage | Food | Room

pub enum ProductState{
	ok
	planned
	unavailable
	endoflife
	error
}

