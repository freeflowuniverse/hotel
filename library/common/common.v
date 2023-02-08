module common

import time
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.crystallib.params

// PRODUCT

pub enum Unit {
	ml
	grams
	units
	cups
	tsp
	tbsp
	person
}

pub enum ProductState{
	ok
	planned
	unavailable
	endoflife
	error
}

pub struct ProductTag {
	name string
}

// goods/services defined with a price, details and standard unit
pub struct Product {
    id string // two digit number
    name string
	description string
    state ProductState
    price library.finance.Price
    unit Unit
	tags []ProductTag
	constituent_products []ProductAmount
	variable_price bool
}

pub struct ProductAmount {
	product Product // actor_character product_id concatenated
	quantity string
	total_price library.finance.Price
}

// Message

enum MessageType {
	complaint
	announcement
	update
	reminder
}

pub struct Message {
	id string
	target_actor_id string
	subject string
	description string
	sender string // todo are these necessary?
	receiver []string // todo are these necessary?
	message_type MessageType
}

// ASSISTANCE REQUEST

pub struct AssistanceRequest {
	id string // id for request
	assistance_id string // 0 for general actors can define their own specific ids
	issue_subject string
	description string
	by_latest time.Time
	response bool = false
	additional_attributes []Attributes
	completed bool
}


