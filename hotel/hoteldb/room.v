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

pub fn (db HotelDB) get_rooms () []Room{
	return db.get_products('room').map(it as Room)
}

pub fn (db HotelDB) get_room (id string) !Room {
	room := db.get_product(id) or {return error("Failed to get room $id: $err")}
	return room as Room
}

pub fn (mut db HotelDB) delete_room (id string) ! {
	db.delete_product(id) or {return error("Failed to delete room $id: $err")}
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

pub fn (mut db HotelDB) add_room (mut o params.Params) !Product {

	room := Room{
		ProductMixin: db.params_to_product(mut o)!
		room_number : o.get('room_number')!
		double_count : o.get('double_count')!.int()
		single_count : o.get('single_count')!.int()
		view : match_view(o.get('view')!)
		ensuite : o.get('ensuite')!.bool()
	}

	return room
}

fn match_view(view_ string) View {
	corrected_view := texttools.name_fix_no_underscore_no_ext(view_)

	view := match corrected_view {
		'sea' {View.sea}
		'garden' {View.garden}
		else {panic("View was inputted incorrectly")} // TODO Need better error reporting
	}

	return view
} 