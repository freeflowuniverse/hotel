module bar

import finance

struct Bar {
	employee_ids []string
	storage_id  string // The idea here is to have your menu defined by contents of supply
	drinks      []Drink
}

struct Purchase {
	id            string
	product_code  string
	quantity      string
	note          string
	table         string
	customer_id   string
	employee_id   string // employee who performed the order
}

struct Drink {
	id      string
	name    string
	ingredients  []IngredientAmount
}

struct Ingredient { // taken from storage product
	id string
	name string
}

struct IngredientAmount {
	ingredient  Ingredient
	amount   Amount
}

struct Amount {
	number  int
	unit    Unit
}

enum Unit {
	ml
	grams
	pieces
	cups
	tsp
	tbsp
}

// Server Guest
// takes in an order (digitally from guest or from employee) and prompts employees to prepare and serve a drink
// FROM USER
fn (bar Bar) serve_guest (order Order) ! {

}

// Play song
// on request from a guest, the bar can play a song
// TO USER
fn (bar Bar) play_song (song_name string) ! {

}

// Charge guest
// after an order is received this is sent to the guest reducing their funds
fn (bar Bar) charge_guest (transaction Transaction) ! {}

// Send funds to accountant
// sends the funds from an order directly to the accountant
fn (bar Bar) send_funds_to_accountant (transaction Transaction) ! {}