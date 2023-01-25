
// GUEST ACTOR -----------------------------

struct Guest {
	id string
	name string
}

struct FoodOrder {
	id string
	product_id string
	time time.Time
	quantity int
	room_service bool
}

struct RoomBooking {
	id string
	product_id string
	time  time.Time
	nights  int
}

struct BoatBooking {
	id string
	product_id string
	time time.Time
	booking_length time.Time
}

type Order = BoatBooking | RoomBooking | FoodOrder 

fn (guest Guest) order_product (order Order) {
	// send a message to appropriate actor to get that product for the guest
}

// RESTAURANT ACTOR -----------------------------

struct Restaurant {
	id string
	name string
}

// needs to match the guest FoodOrder struct
struct FoodOrder {
	id string
	product_id string
	time time.Time
	quantity int
	room_service bool
}

fn (restaurant Restaurant) complete_food_order (order FoodOrder) {
	// call function to see if ingredients are available
	// send message to chef to prepare food
}

// RECEPTION ACTOR -----------------------------

struct Reception {
	id string
	name string
}

// needs to match the guest RoomBooking struct
struct RoomBooking {
	id string
	product_id string
	time  time.Time
	nights  int
}

fn (reception Reception) log_room_booking (booking RoomBooking) {
	// call function to block out the availability of the room
	// send message to cleaners to prepare the room
}

// DOCK ACTOR -----------------------------

struct Dock {
	id string
	name string
}

// needs to match the guest BoatBooking struct
struct BoatBooking {
	id string
	product_id string
	time time.Time
	booking_length time.Time
}

fn (dock Dock) log_boat_booking (booking BoatBooking) {
	// call function to block out the availability of the boat
	// call function to ensure boat is fueled
}