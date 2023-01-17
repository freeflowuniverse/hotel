module hoteldb

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

fn (room Room) stringify () string {
	mut text := room.ProductMixin.stringify()

	view := '$room.view'
	ensuite := '$room.ensuite'

	text += 'Room Number: ${room.room_number}
Double Beds: ${room.double_count}
Single Beds: ${room.single_count}
View: ${view.capitalize()}
Ensuite: ${ensuite.capitalize()}\n'

	return text
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