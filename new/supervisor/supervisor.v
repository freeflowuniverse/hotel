module supervisor

import user

struct Supervisor {
	address_books []AddressBook
}

struct AddressBook {
	name string
	book map[string]string //map[id]address
}

// keeps a map of addresses of actors 
// creates new actors
// reinitialise / delete zombie actors

fn (mut s Supervisor) run () {
	// infinite loop
}

fn (mut s Supervisor) create_user (user_ IUser) {
	guid := s.generate_user_code()
	new_user := user.new(user_)
	spawn new_user.run() // todo will need to refactor
}

fn (mut s Supervisor) designate_access () {

}