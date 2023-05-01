module actor_tests

import freeflowuniverse.hotel.src.ideal_actors.user
import freeflowuniverse.hotel.src.ideal_actors.user.user_model

fn init_user (user_type string) !user.UserActor {
	if user_type == 'guest' {
		user_instance := user_model.Guest{
			telegram_username: 'jonathan1'
			firstname: 'Jonathan'
			lastname: 'Ouwerx'
			email: 'jonathanouwerx@me.com'
			phone_number: '07766222521'
			allergies: ['nuts', 'shellfish']
			preferred_contact: 'email'
			digital_funds: 0
		}
		return user.new(user_instance, '1')!
	} else {
		user_instance := user_model.Employee{
			telegram_username: 'jonathan1'
			firstname: 'Jonathan'
			lastname: 'Ouwerx'
			email: 'jonathanouwerx@me.com'
			phone_number: '07766222521'
			allergies: ['nuts', 'shellfish']
			preferred_contact: 'email'
			digital_funds: 0
			working: true
			actor_names: ['kitchen']
			title: 'Chef'
		}
		return user.new(user_instance, '1')!
	}	
}

fn test_new () ! {
	guest_actor := init_user('guest')!
	employee_actor := init_user('employee')!
}

