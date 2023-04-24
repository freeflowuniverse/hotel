module model


pub struct Supervisor {
SupervisorCore
}

pub struct SupervisorCore {
pub mut:
	address_books []AddressBook
}

pub struct AddressBook {
pub mut:
	actor_name string
	book map[string]string //map[id]address
}