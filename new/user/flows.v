module user

fn main_flow (user_id string) ! {
	// todo do code generation for this
	flow_options := [
		0: 'change_full_name'
	]
	response := ui.ask_dropdown("Which flow would you like to enter?", flow_options)
	
	match flow_options[response] {
		'change_full_name' {change_full_name(user_id)}
	}
}

//flow_method
fn change_full_name (user_id string) ! {
	mut ui := ui_client.new(user_id)

	user_client := user_client.new(user_id)
	first_name := ui.ask_question("Firstname?")
	user_client.change_first_name(first_name)
	last_name := ui.ask_question("Lastname?")
	user_client.change_last_name(last_name)
}

// user.v is a combination of base items

// flows.v puts them together and is asynchronous
