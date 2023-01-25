module Kitchen

struct Kitchen {
	employee_ids []string
	storage_id  string // The idea here is to have your menu defined by contents of supply
	foods      []Food
}

struct Order {
	id            string
	product_code  string
	quantity      string
	note          string
	table         string
	employee_id   string // employee who performed the order
}

struct Food {
	id      string
	name    string
	ingredients  []IngredientAmount
	prep_time  time.Time
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
	number  f64
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