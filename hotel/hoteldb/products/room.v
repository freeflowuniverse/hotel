module hoteldb

import freeflowuniverse.backoffice.finance
import freeflowuniverse.crystalib.params
import freeflowuniverse.crystallib.texttools

pub enum View {
	sea 
	garden
}

pub struct Room{
	ProductMixin
pub mut:
	room_number  string
	double_count int
	single_count int
	view         View 
	ensuite      bool = true
}

pub fn (room Room) capacity () int {
	return room.double_count * 2 + room.single_count
}

pub fn (hdb HotelDB) add_room (o params.Params) {

	room := Room{
		id : o.get('id')
		name : o.get('name')
		url : o.get('url')
		description : o.get('description')
		price : finance.amount_get(o.get('price'))
		state: match_state(o.get('state'))
		room_number : o.get('room_number')
		double_count : o.get('double_count').int()
		single_count : o.get('single_count').int()
		view : match_view(o.get('view'))
		ensuite : o.get('ensuite').bool()
	}

	hdb.products << room
}

pub fn match_view(view_ string) View {
	corrected_view := texttools.name_fix_no_underscore_no_ext(view_)

	view := match corrected_view {
		'ok' {View.sea}
		'planned' {View.garden}
		else {panic("View was inputted incorrectly")} // TODO Need better error reporting
	}

	return view
} 