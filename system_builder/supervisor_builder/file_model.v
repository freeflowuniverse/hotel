module supervisor_builder

import actor_builder as ab

fn (mut sb SupervisorBuilder) create_model () ! {
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
	mut model_dir_path := sb.dir_path.extend_dir_create('supervisor_model')!
	mut model_path := model_dir_path.extend_file('model.v')!
	ab.append_create_file(mut model_path, model_content, [])!
}
