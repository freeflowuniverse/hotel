module supervisor

import freeflowuniverse.hotel.library.models
import freeflowuniverse.hotel.actors.user
import freeflowuniverse.hotel.actors.user.user_client

fn (mut a SupervisorActor) create_user (user_ models.IUser) {
	id := a.generate_id('user')!
	new_user := user.new(user_, id)
	spawn new_user.run() // todo will need to refactor
}

// internal function
fn (a SupervisorActor) generate_id (actor_name string) string {
	books := a.supervisor.address_books.filter(it.actor_name == actor_name)
	if books.len == 0 {
		mut new_book := models.AddressBook{
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

fn (mut a SupervisorActor) designate_access () {

}

// todo test what happens if unfamiliar actor_name used
fn (a SupervisorActor) get_address (actor_name string, actor_id string) !string {
	address_books := a.supervisor.address_books.filter(it.actor_name == actor_name)
	if address_books.len == 0 {
		return error("Actor name not recognised")
	}
	address := address_books[0].book[actor_id]
	if address == '' {
		return error("Actor ID could not be found.")
	}
	return address
}

fn (a SupervisorActor) get_address_book (actor_name string) !map[string]string {
	address_book := a.supervisor.address_books.filter(it.actor_name == actor_name)
	if address_book.len == 0 {
		return error("Actor name not recognised")
	}
	return address_books[0].book
}

fn (a SupervisorActor) find_user (identifier string, identifier_type string) !(models.IUser, string) {
	address_book := a.get_address_book(actor_name)!
	if identifier_type == 'id' {
		if identifier in address_book.book.keys() {
			return address_book.book[identifier]
		} else {
			return error("Identifier could not be found")
		}
	} else {
		for id, address in address_book.book {
			if user, user_type := user_client.get(identifier, identifier_type) {
				return user, user_type
			}
		}
	}
	return error("User not identified in system")
}

// fn (a Supervisor) find_user_async (identifier string, identifier_type string) !(models.IUser, string) {
// 	spawn 
// }