module bar

struct BarSupervisor {
	bar_employees []barstaff.BarEmployee
	storage_id  string // The idea here is to have your menu defined by contents of supply
}

struct BarEmployee{}

struct Order {
	id            string
	product_code  string
	quantity      string
	note          string
	table         string
}

struct Drinks {
	id      string
	name    string
	ingredients  []
}

// Server Customer
// takes in an order and prompts employees to prepare and serve a drink
fn (bar_employee BarEmployee) serve_customer (order Order) ! {

}

fn (bar_employee BarEmployee) play_song (song_name string) ! {

}

fn (bar_employee BarEmployee) check_supply () ! {

}

fn (bar_employee BarEmployee) request_supplies () ! {

}