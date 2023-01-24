module storage

struct Storage {
	id string
	name string
	supplies []ProductAmount
}

struct Product {
	id string
	name string
}

struct ProductAmount {
	product  Product
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
}