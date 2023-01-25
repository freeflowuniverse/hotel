module library

import time

// - Product - a product of some sort ie food, boat, USD (every product has USD value)
// - Amount - a certain amount
// - Information - simple text field
// - TimePeriod - a start and end date where the end date is optional
// - Transfer - a sender and receiver
// - map[string]string - allows for any further attributes to be included

pub struct Product {
	id string
	name string
	description string
	value int // defaults to USD
}

pub struct Price {
	
}

pub struct Amount {
	quantity   string
	unit       Unit
}

enum Unit {
	litres
	grams
	units
	cups
	tsp
	tbsp
	metres
	seconds
}

struct Information {
	subject     string
	content     string
}

struct TimePeriod {
	start time.Time
	end   time.Time
}

struct Transfer {
	sender_id  string
	receiver_id  string
}

