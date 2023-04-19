module client_builder

pub fn new() Builder {
	return Builder{}
}

pub fn build_client(actor_dir_path string) !Builder {
	
	mut b := client_builder.new()
	$if debug { println("Reading directory at: ${actor_dir_path} ...") }
	b.read_actor_dir(actor_dir_path) or {return error("Failed to read actor directory at $actor_dir_path with error:\n$err")}
	$if debug { println("Writing ${b.actor_name}_client...") }
	b.write_client(actor_dir_path + '/${b.actor_name}_client/client.v')!
	$if debug { println(b) }
	return b
}

pub struct Builder {
pub mut:
	actor_name    string
	client_string string
	tests_string  string
	flow_methods  []Method
	actor_methods []Method
	imports       []string
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
	sum_type    string
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
