module supervisor_builder

import actor_builder as ab

pub fn (sb SupervisorBuilder) create_methods () {

	mut create_functions := ''
	for name in sb.actors.map(it.name) {
		create_functions += "
pub fn (isupervisor ISupervisor) create_${name}(${name}_instance ${name}.I${name.capitalize()}) {
	id := isupervisor.generate_id('${name}')! 
	mut new_${name} := ${name}.new(id, ${name}_instance)!
	spawn new_${name}.run()
}
"	}

	methods_content := "module supervisor

import ${sb.actors_root}.supervisor.supervisor_model
import json
import freeflowuniverse.baobab.client as baobab_client
${sb.actors.map('import ${sb.actors_root}.${it.name}').join_lines()}

pub interface ISupervisor {
mut:
	address_books []supervisor_model.AddressBook
}

pub fn (isupervisor ISupervisor) get_address_book(actor_name string) !map[string]string {
	address_book := isupervisor.address_books.filter(it.actor_name == actor_name)
	if address_book.len == 0 {
		return error('Actor name not recognised')
	}
	return address_books[0].book
}

pub fn (isupervisor ISupervisor) get_address(actor_name string, actor_id string) !string {
	actor_book := isupervisor.get_address_book(actor_name)!
	address := actor_book[actor_id]
	if address == '' {
		return error('Actor ID could not be found.')
	}
	return address
}

// internal function
fn (isupervisor ISupervisor) generate_id(actor_name string) string {
	books := isupervisor.address_books.filter(it.actor_name == actor_name)
	if books.len == 0 {
		mut new_book := supervisor_model.AddressBook{
			actor_name: actor_name
		}
		isupervisor.address_books << new_book
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

pub fn (isupervisor ISupervisor) edit_address_book (actor_name string, address_book map[string]string) ! {
	for mut book in isupervisor.address_books {
		if book.actor_name == actor_name {
			book.book = address_book
			return
		}
	}
	return error(\"Failed to find address book with actor name '\$actor_name'!\")
}

pub fn (isupervisor ISupervisor) get() !string {
	if isupervisor is supervisor_model.Supervisor {
		return json.encode(isupervisor)
	}
	panic('This point should never be reached. There is an issue with the code generation! Not all actor flavours have been accounted for.')
}

${create_functions}
"

	methods_path := sb.dir_path.extend_file('methods.v')!
	ab.append_create_file(mut methods_path, methods_content, [])!
}
