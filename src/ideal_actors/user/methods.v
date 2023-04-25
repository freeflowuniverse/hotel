module user

import time
import user_model
import freeflowuniverse.baobab.jobs
import freeflowuniverse.hotel.actors.user
import json

fn (user IUser) get_user(identifier string, identifier_type string) !(IUser, string) {
	match identifier_type {
		'email' {
			if user.email == identifier {
				return user, user.type_name().all_after_last('.')
			}
		}
		'id' {
			if user.id == identifier {
				return user, user.type_name().all_after_last('.')
			}
		}
		'telegram_username' {
			if user.telegram_username == identifier {
				return user, user.type_name().all_after_last('.')
			}
		}
		else {
			return error('Invalid identifier type.')
		}
	}
	return error('Unrecognised identifier.')
}

// todo will need to include validation somehow
fn (user IUser) edit(attribute string, value string) ! {
	match attribute {
		'name' { user.name == value }
		'email' { user.email == value }
		'phone_number' { user.phone_number == value }
		'date_of_birth' { user.date_of_birth == value }
		'allergies' { user.allergies << value }
		'preferred_contact' { user.preferred_contact == value }
		'telegram_username' { user.telegram_username == value }
	}
}

// +++++++++ CODE GENERATION BEGINS BELOW +++++++++

pub fn (iuser IUser) get() !string {
	if iuser is user_model.Guest {
		return json.encode(iuser)
	} else if iuser is user_model.Employee {
		return json.encode(iuser)
	}
	panic('This point should never be reached. There is an issue with the code!')
}

pub interface IUser {
	telegram_username string
	id string
	firstname string
	lastname string
	email string
	phone_number string
	date_of_birth time.Time
	allergies string
	preferred_contact string
	digital_funds f64
}
