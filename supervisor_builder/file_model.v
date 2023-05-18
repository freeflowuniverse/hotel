module supervisor_builder

import actor_builder as ab

fn (sb SupervisorBuilder) create_model () {
	model_content := "module supervisor_model

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
	book       map[string]string // map[id]address
}

pub interface IModelSupervisor {
	address_books []AddressBook
}"

	model_path := sb.dir_path.extend_file('supervisor_model/model.v')!
	ab.append_create_file(mut model_file.path, model_content, [])!
}
