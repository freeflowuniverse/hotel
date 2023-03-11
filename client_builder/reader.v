module client_builder

import os

// todo get outputs from where they are added to the job but first clarify that this is actually where they will be defined

// TODO decide how that dir will be structured
// top level function to read the entire actor including flows and spv methods
pub fn (b Builder) read_actor (dir_path string) {

}

pub fn (mut b Builder) read_spv_file (file_path string) ! {
	text := os.read_file(file_path)!
	b.read_spv_file_text(text)
}

// This must be called before reading the actor flow methods
// STANDARD FORMAT: router function must have the name 'handle_job'
fn (mut b Builder) read_spv_file_text (spv_text string) {

	mut functions := []string{}

	mut finished := false 
	mut remaining := spv_text.replace('\npub fn ', '\nfn ')
	mut function := ''

	for finished == false {
		function, remaining = get_curly_contents(remaining.all_after_first('\nfn ').replace_once('{',''))
		functions << "fn " + function.replace_once('\n', '{\n')
		if remaining.contains('\nfn ') == false {
			finished = true
		}
	}

	mut index := 0
	for function_ in functions {
		if function_.replace(' ', '').contains(')handle_job(') {
			b.client = read_router_function(function_)
			break
		} 
		index += 1
	}

	functions.delete(index)

	b.read_spv_methods(functions)

	b.read_imports(spv_text)

	b.client.name = spv_text.all_after_first('module ').all_before('\n')
}

fn (mut b Builder) read_imports (text string) {
	import_lines := text.split('\n').filter(it.starts_with('import'))
	for method in b.client.spv_methods {
		for _, output in method.outputs {
			for line in import_lines {
				if line.all_after_last('.').all_before(' ') == output.data_type.all_before('.') {
					b.client.imports << line
				}
			}
		}
		for _, input in method.inputs {
			for line in import_lines {
				if line.all_after_last('.').all_before(' ') == input.data_type.all_before('.') {
					b.client.imports << line
				}
			}
		}
	}
}

fn (mut b Builder) read_spv_methods (functions []string) {
	for function in functions {
		first_line := function.all_before('\n').all_after_first(')')
		for mut method in b.client.spv_methods {
			if first_line.contains(method.name) {
				inputs := first_line.find_between('(', ')').split(',')
				for input in inputs {
					method.add_input(input.trim_space().split(' ')[0], input.trim_space().split(' ')[1])
				}
				outputs := first_line.all_after_first(')').trim('{ !?()').split(',')
				mut count := 0
				for output in outputs {
					method.outputs[count].data_type = output.trim_space()
					count += 1
				}
			}
		}	
	}
}

// STANDARD FORMAT: match function must be of the form - match actionname {}
fn read_router_function (router_text string) Client {
	mut spv_front_trimmed := router_text.replace(' ', '').all_after('matchactionname{')
	mut match_function, _ := get_curly_contents(spv_front_trimmed)

	mut branches := map[string]string{}
	mut branch_name := ''
	mut branch_content := ''

	// ? can modify this so that it incorporates get_curly_contents()
	mut depth := 0 
	for chr in match_function {
		if chr.ascii_str() == '{' {
			depth += 1
		} else if chr.ascii_str() == '}' {
			depth -= 1
			if depth == 0 {
				branches[branch_name] = branch_content
				branch_name = ''
				branch_content = ''
 			}
		} else if depth == 0 {
			branch_name += chr.ascii_str()
		} else {
			branch_content += chr.ascii_str()
		}
	}

	return parse_match_map(mut branches)
}

fn parse_match_map (mut branches map[string]string) Client {

	mut client := Client{}
	
	for name_, mut branch_content in branches {
		mut method := Method{}
		mut branch_name := name_.trim_space()
		if branch_name[0].ascii_str() == "'" {
			method.name = branch_name.all_after_first("'").all_before_last("'")
		} else if branch_name[0].ascii_str() == '"'{
			method.name = branch_name.all_after_first('"').all_before_last('"')
		} else {
			method.name = 'else'
		}

		if method.name == 'else' {
			break
		} else if method.name.contains('_flow') == false {
			output_string := branch_content.all_before(method.name).all_after_last('\n').all_before(':=').trim_space()
			for output_ in output_string.split(',') {
				method.add_output(output_.trim_space().trim_left('mut '), '')
			}
			client.spv_methods << method
		} else {
			client.flow_methods << method
		}
	}

	return client
}


// This must be called after reading the supervisor file
// TODO reads the actor file/dir to get the flow methods
fn (b Builder) read_actor_file () {
	
	// todo get all the state access/edit methods
	// for this, the inputs should be read from the first line of the function definition
	// the outputs should be read from the receiving variables for the called function (for the names) and from the first line of the function definition for the type
}

// starts from just within a set of curly brackets ie {* found = true }*
// ie at the * and continues until the closing bracket associated with the '{' preceeding the star
// does not return the closing curly bracket
fn get_curly_contents (text string) (string, string) {
	mut depth := 1
	mut count := 0
	for chr in text {
		if chr.ascii_str() == '{' {
			depth += 1
		} else if chr.ascii_str() == '}' {
			depth -= 1
		}
		if depth == 0 {
			break
		}
		count += 1
	}
	return text[0..count], text[(count+1)..(text.len)]
}
