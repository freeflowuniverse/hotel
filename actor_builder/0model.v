module actor_builder

import freeflowuniverse.crystallib.pathlib

pub struct Builder {
pub mut:
	core_interface Interface
    dir_path       pathlib.Path
    actor_name     string
    actor_methods  []Method
    flow_methods   []Method
}

pub struct Interface {
pub mut:
	flavors []string
	attrs []Param
}

pub struct Method {
pub mut:
	name    string
	inputs  map[int]Param // where int is order that they are given to the function
	outputs map[int]Param // where int is order that they are returned from function
	src_module       Module
	method_type      MethodType
}

pub struct Module {
pub mut:
	name string
	alias string
	selections []string
}

pub enum MethodType {
	custom
	get
}

pub struct Param {
pub mut:
	name             string
	data_type        string
	src_module       Module
}

pub struct File {
pub mut:
	mod string
	imports []Module
	content []string
}

fn (mut imports []Module) add_many (imps_list ...[]Module) {
	for new_imps in imps_list {
		for imp in new_imps {
			imports.add(imp)
		}
	}
}

fn (mut imports []Module) add (new_imp_ Module) {
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
	imports = imports.filter(it.name!='')
}

fn (mut m Method) add_input(name string, data_type string) {
	m.inputs[find_greatest(m.inputs.keys()) + 1] = Param{
		name: name
		data_type: data_type
	}
}

fn (mut m Method) add_output(name string, data_type string, pos_ int) {
	mut pos := pos_
	if pos == -1 {
		pos = find_greatest(m.outputs.keys()) + 1
	}
	m.outputs[pos] = Param{
		name: name
		data_type: data_type
	}
}

fn find_greatest(numbers []int) int {
	mut greatest := -1
	for number in numbers {
		if number > greatest {
			greatest = number
		}
	}
	return greatest
}


