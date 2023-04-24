module actor_builder

import os

fn (b Builder) write_actor () ! {

	mut actor_content := File{
		mod: b.actor_name
	}

	boilerplate_str, boilerplate_imports := b.write_actor_boilerplate()
	actor_content.content << boilerplate_str

	router_str, router_imports := b.write_router() or {return error("Failed to writer router with error: \n$err")}
	actor_content.content << router_str

	actor_content.imports.add_many(boilerplate_imports, router_imports)
	actor_content.imports = actor_content.imports.filter(it.name!='')

	file_str := actor_content.write()

	mut dir_path := b.dir_path

	os.write_file(dir_path.join('actor.v')!.path, file_str) or {return error("Failed to write file with error: $err")}

}

fn (b Builder) write_router () !(string, []Module) {
	mut imports := []Module{}

	mut rstr := 'fn (actor ${b.actor_name.capitalize()}Actor) execute (mut job ActionJob) ! {\n'
	// todo parse actionname from job
	rstr += '\tmatch actionname {\n'

	for method in b.actor_methods {
		method_str, method_imports := b.write_method(method, 'actor') or {return error("Failed to write actor method with error: \n$err")}
		rstr += method_str
		imports.add_many(method_imports)
	}
	rstr += '\t\telse {job.state = .error}\n\t}\n}'

	return rstr, imports
}


fn (b Builder) write_actor_boilerplate () (string, []Module) {
	mut bstr := "\npub struct ${b.actor_name.capitalize()}Actor {\n"
	bstr += "\tid\tstring\n"
	bstr += "\t${b.actor_name}\tI${b.actor_name.capitalize()}\n"
	bstr += "\tbaobab baobab_client.Client\n}\n\n"

	bstr += 'fn (actor ${b.actor_name.capitalize()}Actor) run () {\n\n}' // todo fill out
	
	jobs_mod := Module{
		name: 'freeflowuniverse.baobab.jobs'
		selections: ['ActionJob']
	}

	client_mod := Module{
		name: 'freeflowuniverse.baobab.client'
		alias: 'baobab_client'
	}

	return bstr, [jobs_mod, client_mod]
}