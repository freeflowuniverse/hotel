module accommodation

import time

struct Accommodation {
	bookings []Booking
}

struct Booking {
	room_id string
	check_in time.Time
	check_out time.Time
}

fn (a Accommodation) create_booking {}