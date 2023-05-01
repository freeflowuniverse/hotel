module actor_builder

import os

fn (b Builder) write_client () ! {

	mut actor_content := File{
		mod: '${b.actor_name}_client'
	}

	interface_str, interface_imports := b.write_interface(b.core_interface, 'client')
	actor_content.content << interface_str

	boilerplate_str, boilerplate_imports := b.write_client_boilerplate()
	actor_content.content << boilerplate_str

	for method in b.actor_methods {
		method_str, method_imports := b.write_method(method, 'client') or {return error("Failed to write client method with error: \n$err")}
		actor_content.content << method_str
		actor_content.imports.add_many(method_imports)
	}

	actor_content.imports.add_many(interface_imports, boilerplate_imports)
	actor_content.imports = actor_content.imports.filter(it.name!='')

	file_str := actor_content.write()

	mut dir_path := b.dir_path
	mut client_dir_path := dir_path.extend_dir_create('${b.actor_name}_client')!
	if os.exists(client_dir_path.path) {
		os.rmdir_all(client_dir_path.path) or {return error("Failed to remove ${b.actor_name}_client directory")}
	}
	os.mkdir(client_dir_path.path)!
	os.write_file(client_dir_path.extend_file('/client.v')!.path, file_str) or {return error("Failed to write file with error: $err")}
}


fn (b Builder) write_client_boilerplate () (string, []Module) {
	name := b.actor_name
	capital_name := b.actor_name.capitalize()

	cstr := "
pub struct ${capital_name}Client {
pub mut:
	${name}_address string
	baobab          baobab_client.Client
}

pub fn new(${name}_id string) !${capital_name}Client {
	mut supervisor := supervisor_client.new() or { return error('Failed to create a new supervisor client with error: \\n\$err') }

	address := supervisor.get_address('${name}', ${name}_id) or { return error('Failed to get address of ${name} with given id with error: \\n\$err') }

	return ${capital_name}Client{
		${name}_address: address
		baobab: baobab_client.new('0') or { return error('Failed to create new baobab client with error: \\n\$err') }
	}
}
"

	mut imports := []Module{}

	imports << Module { name: 'json' }
	imports << Module { name: 'freeflowuniverse.baobab.client', alias: 'baobab_client' }
	imports << Module { name: 'freeflowuniverse.hotel.actors.supervisor.supervisor_client' }
	imports << Module { name: 'freeflowuniverse.crystallib.params' }

	return cstr, imports
}


