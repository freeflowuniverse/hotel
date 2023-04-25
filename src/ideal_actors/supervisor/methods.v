module supervisor

import supervisor_model
import freeflowuniverse.hotel.actors.supervisor.supervisor_model
import freeflowuniverse.hotel.actors.user
import freeflowuniverse.hotel.actors.user.user_model
import json

pub fn (mut a SupervisorActor) create_user(user_ user_model.IModelUser) {
	id := a.generate_id('user')!
	new_user := user.new(user_, id)
	spawn new_user.run() // todo will need to refactor
}

// internal function
fn (a SupervisorActor) generate_id(actor_name string) string {
	books := a.supervisor.address_books.filter(it.actor_name == actor_name)
	if books.len == 0 {
		mut new_book := supervisor_model.AddressBook{
			actor_name: actor_name
		}
		a.supervisor.address_books << new_book
		books << new_book
	}
	mut max := 0
	for id in books[0].book.keys() {
		if id.int() > max {
			max = id.int()
		}
	}
	return max.str()
}

pub fn (mut a SupervisorActor) designate_access() {
}

// todo test what happens if unfamiliar actor_name used
pub fn (a SupervisorActor) get_address(actor_name string, actor_id string) !string {
	address_books := a.supervisor.address_books.filter(it.actor_name == actor_name)
	if address_books.len == 0 {
		return error('Actor name not recognised')
	}
	address := address_books[0].book[actor_id]
	if address == '' {
		return error('Actor ID could not be found.')
	}
	return address
}

pub fn (a SupervisorActor) get_address_book(actor_name string) !map[string]string {
	address_book := a.supervisor.address_books.filter(it.actor_name == actor_name)
	if address_book.len == 0 {
		return error('Actor name not recognised')
	}
	return address_books[0].book
}

pub fn (a SupervisorActor) find_user(identifier string, identifier_type string) !(user_model.IModelUser, string) {
	address_book := a.get_address_book(actor_name)!
	if identifier_type == 'id' {
		if identifier in address_book.book.keys() {
			return address_book.book[identifier]
		} else {
			return error('Identifier could not be found')
		}
	} else {
		for id, address in address_book.book {
			if user, user_type := user_client.get(identifier, identifier_type) {
				return user, user_type
			}
		}
	}
	return error('User not identified in system')
}

// fn (a Supervisor) find_user_async (identifier string, identifier_type string) !(models.IUser, string) {
// 	spawn
// }
// +++++++++ CODE GENERATION BEGINS BELOW +++++++++

pub fn (isupervisor ISupervisor) get() !string {
	if isupervisor is supervisor_model.Supervisor {
		return json.encode(isupervisor)
	}
	panic('This point should never be reached. There is an issue with the code!')
}

pub interface ISupervisor {
	address_books []supervisor_model.AddressBook
}