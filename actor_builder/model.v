module actor_builder

import freeflowuniverse.crystallib.pathlib

pub struct Builder {
pub mut:
	actor_name    string
	model         Model
	dir_path      pathlib.Path
	actors_root   string // ie freeflowuniverse.hotel.actors
	actor_methods []Method
}

pub struct Model {
pub mut:
	core_attributes []Param
	structs         []Struct
}

pub struct Struct {
pub mut:
	name                  string
	additional_attributes []Param
	src_module			  Module
}

pub struct File {
pub mut:
	mod     string
	path    pathlib.Path
	imports []Module
	content []string
}

pub struct Chunk {
pub mut:
	content string
	imports []Module
}

pub fn (mut file File) add(chunk Chunk) {
	file.content << chunk.content
	file.imports.add_many(chunk.imports)
}

pub fn (mut file File) write_file() ! {
	append_create_file(mut file.path, file.write(), [])!
}

struct FunctionParams {
	name     string
	receiver Param
	inputs   []Param
	outputs  []Param
	public   bool
	body     string
	type_    Type
}

enum Type {
	classic
	result
	optional
}

pub struct Module {
pub mut:
	name       string
	alias      string
	selections []string
}

// pub interface IMethod {
// mut:
// 	name    	string
// 	actor_name  string
// 	inputs  	[]Param
// 	outputs 	[]Param
// 	src_module       Module
// }

pub struct Method {
pub mut:
	name       string
	actor_name string
	inputs     []Param
	outputs    []Param
	src_module Module
	custom     bool
}

// pub struct GetMethod {
// pub mut:
// 	name    string
// 	actor_name  string
// 	inputs  	[]Param
// 	outputs 	[]Param
// 	src_module       Module
// }

// pub struct GetAttributeMethod {
// pub mut:
// 	name    string
// 	actor_name  string
// 	inputs  	[]Param
// 	outputs 	[]Param
// 	src_module       Module
// }

// pub struct EditAttributeMethod {
// pub mut:
// 	name    string
// 	actor_name  string
// 	inputs  	[]Param
// 	outputs 	[]Param
// 	src_module       Module
// }

pub struct Param {
pub mut:
	name       string
	data_type  string
	src_module Module
}

fn (mut imports []Module) add_many(imps_list ...[]Module) {
	for new_imps in imps_list {
		for imp in new_imps {
			imports.add(imp)
		}
	}
}

fn (mut imports []Module) add(new_imp_ Module) {
	mut new_imp := new_imp_
	for imp in imports {
		if imp.name == new_imp.name {
			return
		}
		if imp.alias == new_imp.alias && new_imp.alias != '' {
			new_imp.alias = new_imp.alias + '_'
		}
	}
	imports << new_imp
	imports = imports.filter(it.name != '')
}


fn (mut imports []Module) deduct_many(imps_list ...[]Module) {
	for new_imps in imps_list {
		for imp in new_imps {
			imports = imports.filter(it.name != imp.name)
		}
	}
}


pub struct SystemParams {
	actors_dir_path pathlib.Path
	actors []ActorParams
}

pub struct ActorParams {
	name string
	methods []string = ['get', 'get_attribute', 'edit_attribute', 'delete']
}

/*
pub struct System {
	actors []ActorBuilder
	supervisor SupervisorBuilder
	interface_manager InterfaceManagerBuilder
}

pub struct ActorBuilder {}
pub struct SupervisorBuilder {}
pub struct InterfaceManagerBuilder {}
*/
