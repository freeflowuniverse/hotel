module common

import time
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.crystallib.params

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


pub fn validate_email(email_ string) bool {
	if email.contains('@') == false || email.contains('.') == false {
		return false
	}
	if email.split('@')[1].split('.')[0].len < 2 {
		return false
	}
	return true
}
