module client_builder

pub struct Builder {
pub mut:
	client Client
	client_string string
}

pub fn new () Builder {
	return Builder{}
}

pub struct Client {
pub mut:
	name string
	flow_methods []Method
	spv_methods []Method
	imports []string
}

pub struct Method {
pub mut:
	name string
	inputs map[int]Data // where int is order that they are given to the function
	outputs map[int]Data // where int is order that they are returned from function
}

pub struct Data {
pub mut:
	name string
	data_type string
}

fn (mut m Method) add_input (name string, data_type string) {
	m.inputs[find_greatest(m.inputs.keys())+1] = Data{
		name: name
		data_type: data_type
	}
}

fn (mut m Method) add_output (name string, data_type string) {
	m.outputs[find_greatest(m.outputs.keys())+1] = Data{
		name: name
		data_type: data_type
	}
}

fn find_greatest (numbers []int) int {
	mut greatest := -1
	for number in numbers {
		if number > greatest {
			greatest = number
		}
	}
	return greatest
}