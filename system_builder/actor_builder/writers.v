module actor_builder

import os
import freeflowuniverse.crystallib.pathlib

// TODO cant use a regular builder, because for loop needs names of all actors
// fn (mut b ActorBuilder) new_supervisor () (string, []Module) {
// 	new_supervisor_func := "pub fn new() !SupervisorActor {
// 	supervisor := supervisor_model.Supervisor{}

// 	for actor in ['user'] {
// 		supervisor.address_books << supervisor_model.AddressBook{actor_name: actor}
// 	}

// 	mut supervisor_actor := SupervisorActor{
// 		id: '0'
// 		supervisor: supervisor
// 		baobab: baobab_client.new()
// 	}

// 	return supervisor_actor
// }"
// 	imports := [Module{name: 'freeflowuniverse.baobab.client', alias: 'baobab_client'}, Module{name: 'freeflowuniverse.hotel.actors.supervisor.supervisor_model'}]
// 	return new_supervisor_func, imports
// }

pub fn append_create_file(mut file_path pathlib.Path, content string, imports []Module) ! {
	mut file_cont := ''
	if file_path.exists() {
		file_cont = os.read_file(file_path.path) or {
			return error('Failed to read file content with error: \n${err}')
		}
	} else if !os.exists(file_path.path_dir()) {
		os.mkdir_all(file_path.path_dir())!
	}

	file_cont += '\n\n' + content

	if imports.len != 0 {
		mut imports_str := []string{}
		for imp in imports {
			if imp_str := write_import(imp) {
				imports_str << imp_str
			}
		}
		imports_str << ''
		mut file_lines := file_cont.split_into_lines()
		file_lines.insert(2, imports_str)
		file_cont = file_lines.join_lines()
	}
	os.write_file(file_path.path, file_cont) or {
		return error('Failed to write content to file with error: \n${err}')
	}
}

fn write_import(import_ Module) ?string {
	if import_.name != '' {
		mut stmt := 'import ${import_.name}'
		if import_.alias != '' && import_.alias != import_.name.all_after_last('.') {
			stmt += ' as ${import_.alias}'
		}
		if import_.selections.len != 0 {
			stmt += ' {'
			for selection in import_.selections {
				stmt += '${selection}, '
			}
			stmt = stmt.trim_string_right(', ')
			stmt += '}'
		}
		return stmt
	}
	return none
}

fn make_object(name string, attributes []Param, public bool, interface_ bool) Chunk {
	mut pubmut := ''
	mut prefix := ''
	mut def := 'struct'
	if public == true {
		prefix = 'pub '
		pubmut = '\npub mut:'
	}
	if interface_ == true {
		prefix = 'pub '
		def = 'interface'
		pubmut = '\nmut:'
	}
	struct_str := '${prefix}${def} ${name.capitalize()} {${pubmut}
${attributes.map('\t' + it.name +
		'\t' + it.data_type).join('\n')}	
}'
	mut imports := []Module{}
	imports << attributes.map(it.src_module)
	return Chunk{struct_str, imports}
}

// takes the inputs of the method and produces
// product_name string, quantity int, product product.Product
fn (inputs []Param) istr() string {
	mut inputs_str := ''
	for input in inputs {
		inputs_str += '${input.name} ${input.data_type}, '
	}
	inputs_str = inputs_str.trim_string_right(', ')
	return inputs_str
}

// takes the outputs of the method and produces
// (string, int, product.Product)
// where the brackets are optional
fn (outputs []Param) ostr(brackets bool) string {
	mut outputs_str := ''
	for output in outputs {
		outputs_str += '${output.data_type}, '
	}
	outputs_str = outputs_str.trim_string_right(', ')
	if outputs.len > 1 && brackets == true {
		outputs_str = '(${outputs_str})'
	}
	return outputs_str
}

pub fn indent(input string, indent int) string {
	indentation := '\t'.repeat(indent)
	return indentation + input.split_into_lines().join('\n' + indentation)
}

fn send_receive_job(inputs_ []Param, outputs_ []Param, actor_name string, method_name string) !(string, []Module) {
	mut imports := []Module{}
	mut inputs := ''
	for _, param in inputs_ {
		if param.data_type.contains('.') {
			inputs += "j_args.kwarg_add('${param.name}', json.encode(${param.name}))\n"
			imports.add(param.src_module)
		} else {
			inputs += "j_args.kwarg_add('${param.name}', ${param.name})\n"
		}
	}
	mut outputs := 'return '
	for _, param in outputs_ {
		if param.data_type.contains('.') {
			outputs += "json.decode(${param.data_type}, response.result.get('${param.name}')!)!, "
			imports.add(param.src_module)
		} else {
			outputs += "response.result.get('${param.name}')!, "
		}
	}
	outputs = outputs.trim_right(', ')

	body := "	mut j_args := params.Params{}
${indent(inputs, 1)}
	mut job := ${actor_name}_client.baobab.job_new(
		action: 'hotel.${actor_name}.${method_name}'
		args: j_args
	)!
	response := ${actor_name}_client.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	${outputs}"

	return body, imports
}

fn make_function(f FunctionParams) (string, []Module) {
	mut imports := []Module{}
	imports << f.inputs.map(it.src_module)
	imports << f.outputs.map(it.src_module)
	mut func := 'fn '
	if f.public {
		func = 'pub ' + func
	}
	if f.receiver.name != '' {
		func += '(mut ${f.receiver.name} ${f.receiver.data_type}) '
		imports << f.receiver.src_module
	}
	func += '${f.name} '
	func += '(' + f.inputs.istr() + ')' + ' '
	func += match f.type_ {
		.classic { '' }
		.result { '!' }
		.optional { '?' }
	}
	func += f.outputs.ostr(true) + ' '
	func += '{\n'
	func += f.body
	func += '\n}'

	return func, imports
}

pub fn (file File) write() string {
	mut file_string := 'module ${file.mod}\n\n'
	for imp in file.imports {
		imp_str := write_import(imp) or { continue } // todo check this is valid
		file_string += '${imp_str}\n'
	}
	for content_item in file.content {
		file_string += '\n\n${content_item}'
	}
	return file_string
}
