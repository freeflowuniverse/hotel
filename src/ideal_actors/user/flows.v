module user

import freeflowuniverse.hotel.actors.kitchen.kitchen_client

fn (user IUser) start_app(user_id string) {
	mut ui := ui_client.new(user_id, user_id)

	// todo do code generation for this
	flow_options := {
		0: 'Kitchen'
		1: 'Your Account'
	}
	response := ui.ask_dropdown('Which flow would you like to enter?', flow_options)

	// todo there is an issue here insofar as you dont know which kitchen to enter.
	/*
	I think you need an intermediary flow/actor ie the hotel which will give you the kitchen selection flow
	flow_options := {
		0: 'Hotel'
		1: 'Your Account'
		... (2: 'School') (For future expansions of the twin)
	}

	// ? hotel := hotel_client.new()

	match response {
		// ? hotel := hotel_client.new()
		'Hotel' {hotel.root_flow(user_id)!}
		// ? The question here is whether the hotel client should be initiated within this branch or up above
	}
	*/

	match flow_options[response] {
		'Kitchen' {
			kitchen := kitchen_client.new(kitchen_id)
			kitchen.root_flow(user_id)!
		}
		'Your Account' {
			account_manager_flow(user_id)!
		}
		else {
			panic('Error: You should never get this error, ui.ask_dropdown failed to check valid input or flow incorrectly designed.')
		}
	}
}

fn account_manager_flow(user_id string) ! {
	mut ui := ui_client.new(user_id, user_id)

	// todo do code generation for this
	flow_options := {
		0: 'Change Account Details'
		1: 'Go Back'
	}
	response := ui.ask_dropdown('What would you like to do?', flow_options)

	match flow_options[response] {
		'Change Account Details' {
			change_account_details_flow(user_id)!
		}
		'Go Back' {
			main_flow(user_id)!
		}
		else {
			panic('Error: You should never get this error, ui.ask_dropdown failed to check valid input or flow incorrectly designed.')
		}
	}
}

fn change_account_details_flow(user_id string) ! {
	mut ui := ui_client.new(user_id, user_id)
	edit_options := {
		0: 'Name'
		1: 'Email'
		2: 'Phone Number'
		3: 'Date of Birth'
		4: 'Allergies'
		5: 'Preferred Route of Contact'
		6: 'Telegram Username'
		7: 'Go Back'
	}

	response := ui.ask_dropdown('Which attribute would you like to edit?', edit_options)

	mut attribute := ''
	mut value := ''

	match flow_options[response] {
		'Name' {
			attribute = 'name'
			value = ui.ask_string('What would you like to change your name to?')
		}
		'Email' {
			attribute = 'email'
			value = ui.ask_email('What would you like to change your email to?')
		}
		'Phone Number' {
			attribute = 'phone_number'
			value = ui.ask_phone_number('What would you like to change your phone number to?')
		}
		'Date of Birth' {
			attribute = 'date_of_birth'
			value = ui.ask_date('What would you like to change your date of birth to?')
		}
		'Allergies' {
			// todo
		}
		'Preferred Route of Contact' {
			// todo
		}
		'Telegram Username' {
			attribute = 'telegram_username'
			value = ui.ask_string('What would you like to change your telegram username to?')
		}
		'Go Back' {
			user_client.account_manager_flow(user_id)!
		}
		else {
			panic('Error: You should never get this error, ui.ask_dropdown failed to check valid input or flow incorrectly designed.')
		}
	}

	user := user_client.new(user_id)
	user.edit(attribute, value)
}

// fn view_flow_options (user_id string) ! {
// 	mut ui :=  ui_client.new(user_id)!

// 	// todo get all the possible actions from every other actor
// 	// todo present all these options to the user in a dropdown list or inline menu
// }

// flow_method
// fn change_full_name (user_id string) ! {
// 	mut ui := ui_client.new(user_id)!

// 	user_client := user_client.new(user_id)
// 	first_name := ui.ask_question("Firstname?")
// 	user_client.change_first_name(first_name)
// 	last_name := ui.ask_question("Lastname?")
// 	user_client.change_last_name(last_name)
// }

// user.v is a combination of base items

// flows.v puts them together and is asynchronous
