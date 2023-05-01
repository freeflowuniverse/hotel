module user

import time
import user_model
import json
import user_client

pub interface IUser {
mut:
	telegram_username string
	id string
	firstname string
	lastname string
	email string
	phone_number string
	date_of_birth time.Time
	allergies []string
	preferred_contact string
	digital_funds f64
}

pub fn (iuser IUser) get () !string {
	if iuser is user_model.Guest {
		return json.encode(iuser)
	} else if iuser is user_model.Employee {
		return json.encode(iuser)
	}
	panic('This point should never be reached. There is an issue with the code!')
}

pub fn (iuser IUser) get_attribute (attribute_name string) !string {
	match attribute_name {
		'telegram_username' {return json.encode(iuser.telegram_username)}
		'id' {return json.encode(iuser.id)}
		'firstname' {return json.encode(iuser.firstname)}
		'lastname' {return json.encode(iuser.lastname)}
		'email' {return json.encode(iuser.email)}
		'phone_number' {return json.encode(iuser.phone_number)}
		'date_of_birth' {return json.encode(iuser.date_of_birth)}
		'allergies' {return json.encode(iuser.allergies)}
		'preferred_contact' {return json.encode(iuser.preferred_contact)}
		'digital_funds' {return json.encode(iuser.digital_funds)}
		else {
			if iuser is user_model.Employee {
				match attribute_name{ 
					'title' { return json.encode(iuser.title) }
					'actor_names' { return json.encode(iuser.actor_names) }
					'shifts' { return json.encode(iuser.shifts) }
					'working' { return json.encode(iuser.working) }
					'holidays_remaining' { return json.encode(iuser.holidays_remaining) }
					else {
						return error("Attribute name '$attribute_name' not recognised by this user instance!")
					}
				}
			}
			return error("Attribute name '$attribute_name' not recognised by this user instance!")
		}
		
	}
} // todo need to add filter

pub fn (mut iuser IUser) edit_attribute (attribute_name string, encoded_value string) ! {
	mut userclient := user_client.new(iuser.id)!
	match attribute_name {
		'telegram_username' {
			ids := userclient.check_all('telegram_username', iuser.telegram_username)!
			if ids.len > 0 {
				return error("This attribute should be unique, however it already exists in User ${ids[0]}!")
			}
			iuser.telegram_username = encoded_value.trim("'").trim('"')
		}
		'id' {
			ids := userclient.check_all('id', iuser.id)!
			if ids.len > 0 {
				return error("This attribute should be unique, however it already exists in User ${ids[0]}!")
			}
			iuser.id = encoded_value.trim("'").trim('"')
		}
		'firstname' { iuser.firstname = encoded_value.trim("'").trim('"') }
		'lastname' { iuser.lastname = encoded_value.trim("'").trim('"') }
		'email' {
			ids := userclient.check_all('email', iuser.email)!
			if ids.len > 0 {
				return error("This attribute should be unique, however it already exists in User ${ids[0]}!")
			}
			iuser.email = encoded_value.trim("'").trim('"')
		}
		'phone_number' {
			ids := userclient.check_all('phone_number', iuser.phone_number)!
			if ids.len > 0 {
				return error("This attribute should be unique, however it already exists in User ${ids[0]}!")
			}
			iuser.phone_number = encoded_value.trim("'").trim('"')
		}
		'date_of_birth' { iuser.date_of_birth = json.decode(time.Time, encoded_value)! }
		'allergies' { iuser.allergies = json.decode([]string, encoded_value)! }
		'preferred_contact' { iuser.preferred_contact = encoded_value.trim("'").trim('"') }
		'digital_funds' { iuser.digital_funds = encoded_value.f64() }
		else {
			if mut iuser is user_model.Employee {
				match attribute_name{
					'title' { iuser.title = encoded_value.trim("'").trim('"') }
					'actor_names' { iuser.actor_names = json.decode([]string, encoded_value)! }
					'shifts' { iuser.shifts = json.decode([]user_model.Shift, encoded_value)! }
					'working' { iuser.working = encoded_value.bool() }
					'remaining_holidays' { iuser.holidays_remaining = encoded_value.int() }
					else {
						return error("Attribute name '$attribute_name' not recognised by this user instance!")
					}
				}
			}
			return error("Attribute name '$attribute_name' not recognised by this user instance!")
		}
	}
}


