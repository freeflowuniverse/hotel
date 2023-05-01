module user_client

import user_model
import time
import json
import freeflowuniverse.baobab.client as baobab_client
import freeflowuniverse.hotel.src.ideal_actors.supervisor.supervisor_client
import freeflowuniverse.crystallib.params

pub interface IClientUser { // ? Should I replace with user_model.IModelUser
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

pub struct UserClient {
pub mut:
	user_address string
	baobab       baobab_client.Client
}

pub fn new(user_id string) !UserClient {
	mut supervisor := supervisor_client.new() or {
		return error('Failed to create a new supervisor client with error: ${err}')
	}
	user_address := supervisor.get_address('user', user_id)!
	return UserClient{
		user_address: user_address
		baobab: baobab_client.new('0') or {return error("Failed to create new baobab client with error: \n$err")}
	}
}

pub fn (mut userclient UserClient) get() !IClientUser {
	j_args := params.Params{}
	mut job := userclient.baobab.job_new(
		action: 'hotel.user.get'
		args: j_args
	)!
	response := userclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	if decoded := json.decode(user_model.Guest, response.result.get('encoded_user')!) {
		return decoded
	}
	if decoded := json.decode(user_model.Employee, response.result.get('encoded_user')!) {
		return decoded
	}
	return error('Failed to decode user type')
}

// todo fix the generic portion of this function
pub fn (mut userclient UserClient) get_attribute_json (attribute_name string) !string {
	mut j_args := params.Params{}
	j_args.kwarg_add('attribute_name', attribute_name)
	mut job := userclient.baobab.job_new(
		action: 'hotel.user.get_attribute'
		args: j_args
	)!
	response := userclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return response.result.get('encoded_attribute')!
}


pub fn (mut userclient UserClient) get_telegram_username () !string {
	mut encoded := userclient.get_attribute_json('telegram_username')!
	return encoded.trim('"').trim("'")
}

pub fn (mut userclient UserClient) get_id () !string {
	mut encoded := userclient.get_attribute_json('id')!
	return encoded.trim('"').trim("'")
}

pub fn (mut userclient UserClient) get_firstname () !string {
	mut encoded := userclient.get_attribute_json('firstname')!
	return encoded.trim('"').trim("'")
}

pub fn (mut userclient UserClient) get_lastname () !string {
	mut encoded := userclient.get_attribute_json('lastname')!
	return encoded.trim('"').trim("'")
}

pub fn (mut userclient UserClient) get_email () !string {
	mut encoded := userclient.get_attribute_json('email')!
	return encoded.trim('"').trim("'")
}

pub fn (mut userclient UserClient) get_phone_number () !string {
	mut encoded := userclient.get_attribute_json('phone_number')!
	return encoded.trim('"').trim("'")
}

pub fn (mut userclient UserClient) get_date_of_birth () !time.Time {
	mut encoded := userclient.get_attribute_json('date_of_birth')!
	return json.decode(time.Time, encoded)!
}

pub fn (mut userclient UserClient) get_allergies () ![]string {
	mut encoded := userclient.get_attribute_json('allergies')!
	return json.decode([]string, encoded)!
}

pub fn (mut userclient UserClient) get_digital_funds () !f64 {
	mut encoded := userclient.get_attribute_json('digital_funds')!
	return encoded.f64()
}

pub fn (mut userclient UserClient) get_title () !string {
	mut encoded := userclient.get_attribute_json('title')!
	return encoded.trim('"').trim("'")
}

pub fn (mut userclient UserClient) get_actor_names () ![]string {
	mut encoded := userclient.get_attribute_json('actor_names')!
	return json.decode([]string, encoded)!
}

pub fn (mut userclient UserClient) get_shifts () ![]user_model.Shift {
	mut encoded := userclient.get_attribute_json('shifts')!
	return json.decode([]user_model.Shift, encoded)!
}

pub fn (mut userclient UserClient) get_working () !bool {
	mut encoded := userclient.get_attribute_json('working')!
	return encoded.bool()
}

pub fn (mut userclient UserClient) get_holidays_remaining () !int {
	mut encoded := userclient.get_attribute_json('holidays_remaining')!
	return encoded.int()
}

pub fn (mut userclient UserClient) edit_telegram_username (value string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('telegram_username', encoded)!
}

pub fn (mut userclient UserClient) edit_id (value string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('id', encoded)!
}

pub fn (mut userclient UserClient) edit_firstname (value string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('firstname', encoded)!
}

pub fn (mut userclient UserClient) edit_lastname (value string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('lastname', encoded)!
}

pub fn (mut userclient UserClient) edit_email (value string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('email', encoded)!
}

pub fn (mut userclient UserClient) edit_phone_number (value string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('phone_number', encoded)!
}

pub fn (mut userclient UserClient) edit_date_of_birth (value time.Time, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('date_of_birth', encoded)!
}

pub fn (mut userclient UserClient) edit_allergies (value []string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('allergies', encoded)!
}

pub fn (mut userclient UserClient) edit_preferred_contact (value string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('preferred_contact', encoded)!
}

pub fn (mut userclient UserClient) edit_digital_funds (value f64, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('digital_funds', encoded)!
}

pub fn (mut userclient UserClient) edit_title (value string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('title', encoded)!
}

pub fn (mut userclient UserClient) edit_actor_names (value []string, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('actor_names', encoded)!
}

pub fn (mut userclient UserClient) edit_shifts (value []user_model.Shift, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('shifts', encoded)!
}

pub fn (mut userclient UserClient) edit_working (value bool, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('working', encoded)!
}

pub fn (mut userclient UserClient) edit_holidays_remaining (value int, replace_all bool) ! {
	encoded := json.encode(value)
	userclient.edit_attribute('holidays_remaining', encoded)!
}

// todo fix the generic portion of this function
pub fn (mut userclient UserClient) edit_attribute (attribute_name string, encoded_value string) ! {
	mut j_args := params.Params{}
	j_args.kwarg_add('attribute_name', attribute_name)
	j_args.kwarg_add('encoded_value', value)
	mut job := userclient.baobab.job_new(
		action: 'hotel.user.edit_attribute'
		args: j_args
	)!
	response := userclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
}

pub fn (mut userclient UserClient) delete () ! {
	mut j_args := params.Params{}
	mut job := userclient.baobab.job_new(
		action: 'hotel.user.delete'
		args: j_args
	)!
	response := userclient.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
}

pub fn (mut userclient UserClient) get_all () ![]IClientUser {
	mut supervisor := supervisor_client.new() or {
		return error('Failed to create a new supervisor client with error: ${err}')
	}
	address_book := supervisor.get_address_book('user')!
	mut users := []IClientUser{}
	for _, address in address_book {
		if address != userclient.user_address {
			mut user_client := UserClient{
				user_address: address
				baobab: baobab_client.new('0')!
			}
			users << user_client.get() or {return error("Failed to get user instance with user_client with error: \n$err")}
		}
	
	}
	return users
}

// todo fix the generic portion of this function
pub fn (mut userclient UserClient) check_all[T] (attribute_name string, check_value T) ![]string {
	mut supervisor := supervisor_client.new() or {
		return error('Failed to create a new supervisor client with error: ${err}')
	}
	address_book := supervisor.get_address_book('user')!
	mut matching_users := []string{}
	for id, address in address_book {
		if address != userclient.user_address {
			mut user_client := UserClient{
				user_address: address
				baobab: baobab_client.new('0')!
			}
			match attribute_name {
				'telegram_username' {
					user_attribute := userclient.get_telegram_username()!
					if user_attribute == check_value { matching_users << id }
				}
				'id' {
					user_attribute := userclient.get_id()!
					if user_attribute == check_value { matching_users << id }
				}
				'firstname' {
					user_attribute := userclient.get_firstname()!
					if user_attribute == check_value { matching_users << id }
				}
				'lastname' {
					user_attribute := userclient.get_lastname()!
					if user_attribute == check_value { matching_users << id }
				}
				'email' {
					user_attribute := userclient.get_email()!
					if user_attribute == check_value { matching_users << id }
				}
				'phone_number' {
					user_attribute := userclient.get_phone_number()!
					if user_attribute == check_value { matching_users << id }
				}
				'date_of_birth' {
					user_attribute := userclient.get_date_of_birth()!
					if user_attribute == check_value { matching_users << id }
				}
				'allergies' {
					user_attribute := userclient.get_allergies()!
					if user_attribute == check_value { matching_users << id }
				}
				'preferred_contact' {
					user_attribute := userclient.get_preferred_contact()!
					if user_attribute == check_value { matching_users << id }
				}
				'digital_funds' {
					user_attribute := userclient.get_digital_funds()!
					if user_attribute == check_value { matching_users << id }
				}
				'title' {
					user_attribute := userclient.get_title()!
					if user_attribute == check_value { matching_users << id }
				}
				'actor_names' {
					user_attribute := userclient.get_actor_names()!
					if user_attribute == check_value { matching_users << id }
				}
				'shifts' {
					user_attribute := userclient.get_shifts()!
					if user_attribute == check_value { matching_users << id }
				}
				'working' {
					user_attribute := userclient.get_working()!
					if user_attribute == check_value { matching_users << id }
				}
				'holidays_remaining' {
					user_attribute := userclient.get_holidays_remaining()!
					if user_attribute == check_value { matching_users << id }
				}
				else {}
			}
			user_attribute := user_client.get_attribute[T](attribute_name)!
			if user_attribute == check_value {
				matching_users << id
			}
		}
	}
	return matching_users
}
