module hoteldb

import freeflowuniverse.backoffice.finance
import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.texttools

pub enum View {
	sea 
	garden
}

[heap]
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

pub fn (mut db HotelDB) add_room (mut o params.Params) ! {

	room := Room{
		ProductMixin: db.params_to_product(mut o)!
		room_number : o.get('room_number')!
		double_count : o.get('double_count')!.int()
		single_count : o.get('single_count')!.int()
		view : match_view(o.get('view')!)
		ensuite : o.get('ensuite')!.bool()
	}

	db.products << room
}

pub fn match_view(view_ string) View {
	corrected_view := texttools.name_fix_no_underscore_no_ext(view_)

	view := match corrected_view {
		'sea' {View.sea}
		'garden' {View.garden}
		else {panic("View was inputted incorrectly")} // TODO Need better error reporting
	}

	return view
} 