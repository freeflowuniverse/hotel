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
	mut client_dir_path := dir_path.join('${b.actor_name}_client')!
	if os.exists(client_dir_path.path) {
		os.rmdir_all(client_dir_path.path) or {return error("Failed to remove ${b.actor_name}_client directory")}
	}
	os.mkdir(client_dir_path.path)!
	os.write_file(client_dir_path.join('/client.v')!.path, file_str) or {return error("Failed to write file with error: $err")}
}


fn (b Builder) write_client_boilerplate () (string, []Module) {
	mut cstr := '\npub struct ${b.actor_name.capitalize()}Client {\n'
	cstr += '\t${b.actor_name}_address\tstring\n'
	cstr += '\tbaobab\tbaobab_client.Client\n'
	cstr += '}\n\n'
	cstr += 'pub fn new(${b.actor_name}_id string) !${b.actor_name.capitalize()}Client {\n'
	cstr += '\tsupervisor := supervisor_client.new("0") or {return error("Failed to create a new supervisor client with error: \$err")}\n'
	cstr += '\t${b.actor_name}_address := supervisor.get_address("${b.actor_name}", ${b.actor_name}_id)!\n'
	cstr += '\treturn ${b.actor_name.capitalize()}Client{\n'
	cstr += '\t\tbaobab: baobab_client.new()\n\t}\n}\n\n'

	mut imports := []Module{}

	imports << Module { name: 'json' }
	imports << Module { name: 'freeflowuniverse.baobab.client', alias: 'baobab_client' }
	imports << Module { name: 'freeflowuniverse.hotel.actors.supervisor.supervisor_client' }
	imports << Module { name: 'freeflowuniverse.crystallib.params' }

	return cstr, imports
}

