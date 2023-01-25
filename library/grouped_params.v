// GUEST ACTOR

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

fn (guest Guest) order_product (product library.Product, amount library.Amount, time_period library.TimePeriod, params Params) {
	// send a message to appropriate actor to get that product for the guest
}

// RESTAURANT ACTOR

struct Restaurant {
	id string
	name string
}

// can be a custom food order struct
struct FoodOrder {
	id string
	product_id string
	time time.Time
	quantity int
	room_service bool
}

fn (restaurant Restaurant) complete_food_order (product library.Product, amount library.Amount, time_period library.TimePeriod, params Params) {
	food_order := FoodOrder{
		id: generate_new_id()
		product_id: product.id
		time: time_period.start
		quantity: amount.quantity
		room_service := match params.get('room_service') {
			'true' {true}
			'false' {false}
		}
	}
	// call function to see if ingredients are available
	// send message to chef to prepare food
}

// RECEPTION ACTOR

struct Reception {
	id string
	name string
}

// can be a custom booking struct
struct Booking {
	id string
	product_id string
	time  time.Time
	nights  int
}

fn (reception Reception) log_room_booking (product library.Product, amount library.Amount, time_period library.TimePeriod, params Params) {
	booking := Booking{
		id: generate_new_id()
		product_id: product.id
		time: time_period.start
		nights: convert_to_nights(time_period.end-time_period.start)
	}
	
	// call function to block out the availability of the room
	// send message to cleaners to prepare the room
}

// DOCK ACTOR

struct Dock {
	id string
	name string
}

// can be a custom booking struct
struct Booking {
	id string
	product_id string
	start time.Time
	end time.Time
}

fn (dock Dock) log_boat_booking (product library.Product, amount library.Amount, time_period library.TimePeriod, params Params) {
	booking := Booking{
		id: generate_new_id()
		product_id: product.id
		start: time_period.start
		end: time_period.end
	}
	
	// call function to block out the availability of the boat
	// call function to ensure boat is fueled
}