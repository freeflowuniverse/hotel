module user

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.hotel.actors.user

fn (user IUser) get (identifier string, identifier_type string) !(IUser, string) {

	match identifier_type {
		'email' {
			if user.email == identifier { return user, user.type_name().all_after_last('.') }
		}
		'id' {
			if user.id == identifier { return user, user.type_name().all_after_last('.') }
		}
		'telegram_username' {
			if user.telegram_username == identifier { return user, user.type_name().all_after_last('.') }
		}
		else { return error("Invalid identifier type.")}
	}
	return error("Unrecognised identifier.")
}	

// todo will need to include validation somehow
fn (user IUser) edit (attribute string, value string) ! {
	match attribute {
		'name' {user.name == value}
		'email' {user.email == value}
		'phone_number' {user.phone_number == value}
		'date_of_birth' {user.date_of_birth == value}
		'allergies' {user.allergies << value}
		'preferred_contact' {user.preferred_contact == value}
		'telegram_username' {user.telegram_username == value}
	}
}
