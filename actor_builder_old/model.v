module actor_builder_old

import freeflowuniverse.crystallib.pathlib

pub struct Builder {
pub mut:
    dir_path       pathlib.Path
    actor_name     string
    actor_methods  []Method
    flow_methods   []Method
    instance_flavors []string
    core_struct_attrs  map[string]string
	core_struct_imports []string
    client_imports []string
    client_text  string
    actor_text   string
}

pub struct Method {
pub mut:
	name    string
	inputs  map[int]Data // where int is order that they are given to the function
	outputs map[int]Data // where int is order that they are returned from function
}

pub struct Data {
pub mut:
	name        string
	data_type   string
	// sum_type    string // ! This is not needed for now, but might need to be reimplemented
	import_stmt string
}


fn (mut m Method) add_input(name string, data_type string) {
	m.inputs[find_greatest(m.inputs.keys()) + 1] = Data{
		name: name
		data_type: data_type
	}
}

fn (mut m Method) add_output(name string, data_type string, pos_ int) {
	mut pos := pos_
	if pos == -1 {
		pos = find_greatest(m.outputs.keys()) + 1
	}
	m.outputs[pos] = Data{
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
