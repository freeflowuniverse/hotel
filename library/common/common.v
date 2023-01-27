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

// goods/services defined with a price, details and standard unit
pub struct Product {
    product_id string // two digit number
    name string
	description string
    state ProductState
    price library.Price
    unit Unit
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
	subject string
	description string
	sender string
	receiver []string
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
}


