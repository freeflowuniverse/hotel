module actor_builder

fn (b Builder) write_interface (inter Interface, name string) (string, []Module) {
	mut imports := []Module{}
	mut interface_str := '\npub interface I${name.capitalize()}${b.actor_name.capitalize()} {\n'
	for param in inter.attrs {
		interface_str += '\t${param.name}\t${param.data_type}\n'
		imports.add(param.src_module)
	}
	interface_str += '}'
	return interface_str, imports
}

fn (b Builder) write_method (method Method, target_file_name string) !(string, []Module) {
	
	trimmed_name := target_file_name.trim_string_right('.v')

	method_str, mut imports := match method.method_type {
		.custom {
			match trimmed_name {
				'actor' {b.write_method_to_actor(method)}
				'client' {b.write_method_to_client(method)}
				else {'', []Module{}}
			}
		}
		.get {
			match trimmed_name {
				'methods' {b.write_get_method_to_methods(method)}
				'actor' {b.write_method_to_actor(method)}
				'client' {b.write_get_method_to_client(method)}
				else {'', []Module{}}
			}
		}
	}

	if trimmed_name in ['methods', 'client'] && method.method_type == .get {
		mut dir_path := b.dir_path
		file, _ := parse_file(dir_path.join('/${b.actor_name}_model/model.v')!)
		imports << Module{
			name: file.mod.name // TODO for some reason this returns just model?
		}
	}

	if method_str == '' {
		return error("The intended destination file '${target_file_name}.v' and the method type '${method.method_type}' don't match!")
	}

	return method_str, imports
}

fn (b Builder) write_get_method_to_methods (method Method) (string, []Module) {

	imports := []Module{}

	mut gs := ''
	gs += write_function_header('I${b.actor_name.capitalize()}', 'get', method.inputs.values(), method.outputs.values(), .result)
	gs += '\t'
	for flavor in b.core_interface.flavors {
		gs += 'if i${b.actor_name} is $flavor {\n\t\treturn json.encode(i${b.actor_name})\n\t} else '
	}
	gs = gs.trim_right(' else ')
	gs += '\n\tpanic("This point should never be reached. There is an issue with the code!")\n}'

	return gs, imports
}


fn (b Builder) write_get_method_to_client (method Method) (string, []Module) {
	// import freeflowuniverse.hotel.actors.kitchen.model // TODO from the get method add to imports
	outputs := [Param{
		data_type: 'IClient${b.actor_name.capitalize()}'
	}]
	mut mstr := write_function_header('${b.actor_name.capitalize()}Client', method.name, method.inputs.values(), outputs, .result)
	bstr, imports := b.write_client_method_body(method)
	mstr += bstr

	for flavor in b.core_interface.flavors {
		mstr += '\tif decoded := json.decode($flavor, response) {\n'
		mstr += '\t\treturn decoded\n\t}\n'
	}
	mstr += '\treturn error("Failed to decode ${b.actor_name} type")'
	mstr += '\n}\n\n'
	return mstr, imports
}

fn (b Builder) write_method_to_client (method Method) (string, []Module) {
	mut mstr := write_function_header('${b.actor_name.capitalize()}Client', method.name, method.inputs.values(), method.outputs.values(), .result)
	bstr, imports := b.write_client_method_body(method)
	mstr += bstr

	mstr += '\treturn '
	for _, data in method.outputs {
		if data.data_type.contains('.') {
			mstr += "json.decode(${data.data_type}, response.result.get('${data.name}')!)!, "
		} else {
			mstr += "response.result.get('${data.name}')!, "
		}
	}
	mstr = mstr.trim_right(', ')
	mstr += '\n}\n\n'
	return mstr, imports
}


fn (b Builder) write_client_method_body (method Method) (string, []Module) {
	mut imports := []Module{}
	mut bstr := '\tj_args := params.Params{}\n'
	for _, param in method.inputs {
		if param.data_type.contains('.') {
			bstr += "\tj_args.kwarg_add('${param.name}', json.encode(${param.name}))\n"
			imports.add(param.src_module)
		} else {
			bstr += "\tj_args.kwarg_add('${param.name}', ${param.name})\n"
		}
	}
	bstr += '\tjob := flows.baobab.job_new(\n'
	bstr += "\t\taction: 'hotel.${b.actor_name}.${method.name}'\n"
	bstr += '\t\targs: j_args\n'
	bstr += '\t)!\n'
	bstr += '\tresponse := client.baobab.job_schedule_wait(job, 100)!\n'
	bstr += '\tif response.state == .error {\n'
	bstr += "\t\treturn error('Job returned with an error')\n\t}\n"

	return bstr, imports
}

fn write_import (import_ Module) ?string {
	if import_.name != '' {
		mut stmt := 'import $import_.name'
		if import_.alias != '' && import_.alias != import_.name.all_after_last('.') {
			stmt += ' as $import_.alias'
		} 
		if import_.selections.len != 0 {
			stmt += ' {'
			for selection in import_.selections {
				stmt += '$selection, '
			}
			stmt = stmt.trim_string_right(', ')
			stmt += '}'
		}
		return stmt
	}
	return none
}

pub fn (file File) write () string {
	mut file_string := 'module $file.mod\n\n' 
	for imp in file.imports {
		imp_str := write_import(imp) or {continue} // todo check this is valid
		file_string += '$imp_str\n'
	}
	for content_item in file.content {
		file_string += '$content_item\n\n'
	}
	return file_string
}

fn (b Builder) write_method_to_actor (method Method) (string, []Module) {
	mut imports := []Module{}
	mut mstr := ''
	mstr += "\t\t'$method.name' {\n"
	for _, input in method.inputs {
		if input.data_type.contains('.') {
			mstr += "\t\t\t${input.name} := json.decode(${input.data_type}, job.args.get('${input.name}')!)\n"
		} else {
			mstr += "\t\t\t${input.name} := job.args.get('${input.name}')!\n"
		}
		imports << input.src_module
	}
	mstr += "\t\t\t"
	if method.outputs.len > 0 {
		mstr += "${method.outputs.values().map(it.name).join(', ')} := "
	}
	mstr += "actor.${b.actor_name}.${method.name}(${method.inputs.values().map(it.name).join(', ')})\n"

	for _, output in method.outputs {
		mut value := output.name
		if output.data_type.contains('.') {
			value = 'json.encode(${output.name})'
		}
		mstr += "\t\t\tjob.result.kwarg_add('$output.name', $value)\n"
		imports << output.src_module
	}
	mstr += '\t\t}\n'
	return mstr, imports
}

pub enum FunctionType {
	classic
	result
	optional
}

fn write_function_header (receiver_type string,  fn_name string, inputs []Param, outputs []Param, function_type FunctionType) string {
	mut hstr := 'pub fn '
	if receiver_type != '' {
		hstr += '(${receiver_type.to_lower()} $receiver_type) '
	}
	hstr += '$fn_name ('
	for param in inputs {
		hstr += '${param.name} ${param.data_type}, '
	}
	hstr = hstr.trim_right(', ')
	hstr += ') '
	hstr += match function_type {
		.classic {''}
		.result {'!'}
		.optional {'?'}
	}
	if outputs.len == 1 {
		hstr += '${outputs[0].data_type} '
	} else if outputs.len > 1 {
		hstr += '('
		for param in outputs {
			hstr += '${param.data_type}, '
		}
		hstr = hstr.trim_right(', ')
		hstr += ')'
	}
	hstr +=  ' {\n'

	return hstr
}
