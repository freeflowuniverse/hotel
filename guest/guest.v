module guest

import person
import time

struct Guest {
person.Person
}

struct Order {
	id            string
	product_code  string
	quantity      string
	note          string
	start         time.Time
	end           time.Time
	delivery_time string
	room_service  bool
}

struct Complaint {
	id string
	subject string
	complaint string
}

struct Update {
	id     string
	subject string
	content  string
	from   string
	start    time.Time
	end time.Time
}

// ? I dont think checkin is necessary

// order product
// FROM USER
fn (guest Guest) order_product (order Order) ! {}

// modify product order
// FROM USER
fn (guest Guest) modify_product_order (order_id string, order Order) ! {}

// cancel product order
// FROM USER
fn (guest Guest) cancel_product_order (order_id string) ! {}

// submit complaint
// FROM USER
fn (guest Guest) submit_complaint (complaint Complaint) ! {}

// checkout
// FROM USER
fn (guest Guest) checkout () ! {}

// deduct funds
// this is called by the dock, restaurant, bar, etc after a product order is received
// INTERNAL
fn (mut guest Guest) deduct_funds (amount finance.Amount) ! {}

// announce upcoming event
// sends a message to the user announcing an upcoming event, either self-booked or public
// TO USER
fn (guest Guest) send_update (update Update) ! {}

// request bar song
// allows the guest to request a certain song at the bar
fn (guest Guest) request_song (song_name string, actor_id string, instance_id string) ! {}