module actor_builder

fn (mut b ActorBuilder) create_client() ! {
	mut client_file := File{
		mod: '${b.actor_name}_client'
		path: b.dir_path.extend_file('${b.actor_name}_client/client.v')!
	}
	new_params := [Param{name:'${b.actor_name}_address', data_type: 'string'}, 
				   Param{name: 'baobab', data_type: 'Client', src_module: 
				   		Module{name: 'freeflowuniverse.baobab.client', alias: 'baobab_client'}}]
	client_file.add(make_object('${b.actor_name.capitalize()}Client', new_params, true, false))
	client_file.add(b.new_client())
	client_file.add(b.custom_client()!)
	client_file.add(b.get_client()!)
	client_file.add(b.delete_client()!)
	client_file.add(b.get_attribute_client()!)
	client_file.add(b.edit_attribute_client()!)
	client_file.add(b.get_all_client()!)
	client_file.add(b.search_attribute_client()!)
	client_file.write_file()!
}

fn (b ActorBuilder) new_client() Chunk {
	name := b.actor_name
	client_body := "
	mut supervisor := supervisor_client.new() or {
		return error('Failed to create a new supervisor client with error: \\n\$err')
	}
	${name}_address := supervisor.get_address('${name}', ${name}_id)!
	return ${name.capitalize()}Client{
		${name}_address: ${name}_address
		baobab: baobab_client.new('0') or {
			return error('Failed to create new baobab client with error: \\n\$err')
		}
	}"

	client_str, mut imports := make_function(
		name: 'new'
		inputs: [Param{
			name: '${b.actor_name}_id'
			data_type: 'string'
		}]
		outputs: [Param{
			data_type: '${b.actor_name.capitalize()}Client'
		}]
		public: true
		body: client_body
		type_: .result
	)

	imports.add_many([
		Module{
			name: 'freeflowuniverse.baobab.client'
			alias: 'baobab_client'
		},
		Module{
			name: '${b.actors_root}.supervisor.supervisor_client'
		}])

	return Chunk{client_str, imports}
}

fn (b ActorBuilder) custom_client () !Chunk {
	mut main_chunk := Chunk{}
	for method in b.actor_methods {
		if method.custom == true {
			chunk := method.client() or {
				return error('Failed to create client interface of a method with error: \n${err}')
			}
			main_chunk.imports.add_many(chunk.imports)
			main_chunk.content += '\n\n${chunk.content}'
		}
	}
	return main_chunk
}

pub fn (method Method) client() !Chunk {
	if method.custom == false {
		return Chunk{'', []Module{}}
	}

	body, mut imports := send_receive_job(method.inputs, method.outputs, method.actor_name,
		method.name)!

	func, func_imports := make_function(
		name: method.name
		receiver: Param{
			name: '${method.actor_name}_client'
			data_type: '${method.actor_name.capitalize()}Client'
		}
		inputs: method.inputs
		outputs: method.outputs
		public: true
		body: body
		type_: .result
	)
	imports.add_many(func_imports)
	return Chunk{func, imports}
}

pub fn (mut b ActorBuilder) get_client() !Chunk {
	mut body, mut imports := send_receive_job([], [], b.actor_name, 'get')!
	body = body.all_before_last('\treturn') // ? check if fixed

	for flavor in b.model.structs.map(it.name) {
		body += '\tif decoded := json.decode(${flavor}, response) {\n'
		body += '\t\treturn decoded\n\t}\n'
	}
	body += '\treturn error("Failed to decode ${b.actor_name} type")'

	get_str, func_imports := make_function(
		name: 'get'
		receiver: Param{
			name: '${b.actor_name}_client'
			data_type: '${b.actor_name.capitalize()}Client'
		}
		outputs: [Param{
			data_type: 'IModel${b.actor_name.capitalize()}'
			src_module: Module{name: '${b.actors_root}.${b.actor_name}.${b.actor_name}_model'}
		}]
		public: true
		body: body
		type_: .result
	)
	imports.add_many([Module{name: 'json'}, Module{name: 'freeflowuniverse.crystallib.params'}, b.model.structs[0].src_module], func_imports)

	return Chunk{get_str, imports}
}

pub fn (mut b ActorBuilder) get_attribute_client() !Chunk {
	inputs := [Param{
		name: 'attribute_name'
		data_type: 'string'
	}]
	outputs := [Param{
		name: 'encoded_attribute'
		data_type: 'string'
	}]

	mut body, mut imports := send_receive_job(inputs, outputs, b.actor_name, 'get_attribute')!

	mut str, func_imports := make_function(
		name: 'get_attribute'
		receiver: Param{
			name: '${b.actor_name}_client'
			data_type: '${b.actor_name.capitalize()}Client'
		}
		inputs: inputs
		outputs: outputs
		public: false
		body: body
		type_: .result
	)

	mut params := b.model.core_attributes.clone()	
	for struct_ in b.model.structs {
		params << struct_.additional_attributes
	}

	for param in params {
		body = "\tmut encoded := ${b.actor_name}_client.get_attribute('${param.name}')\n\treturn "
		if param.data_type.contains_any('.[]') { // TODO check if this is comprehensive
			// println(param.data_type)
			// println('json.decode(${param.data_type}, encoded)!')
			body += 'json.decode(${param.data_type}, encoded)!'
		} else if param.data_type == 'string' {
			body += 'encoded.trim(\'"\').trim("\'")'
		} else {
			body += 'encoded.${param.data_type}()'
		}
		minor_get, minor_get_imports := make_function(
			name: 'get_${param.name}'
			receiver: Param{
				name: '${b.actor_name}_client'
				data_type: '${b.actor_name.capitalize()}Client'
			}
			outputs: [param]
			public: true
			body: body
			type_: .result
		)
		str += "\n\n" + minor_get
		imports.add_many(func_imports, minor_get_imports)
	}

	return Chunk{str, imports}
}

pub fn (mut b ActorBuilder) edit_attribute_client() !Chunk {
	inputs := [Param{
		name: 'attribute_name'
		data_type: 'string'
	}, Param{
		name: 'encoded_value'
		data_type: 'string'
	}]

	mut body, mut imports := send_receive_job(inputs, [], b.actor_name, 'edit_attribute')!

	mut str, func_imports := make_function(
		name: 'edit_attribute'
		receiver: Param{
			name: '${b.actor_name}_client'
			data_type: '${b.actor_name.capitalize()}Client'
		}
		inputs: inputs
		outputs: []
		public: false
		body: body
		type_: .result
	)
	imports.add_many(func_imports)

	mut params := b.model.core_attributes.clone()
	for struct_ in b.model.structs {
		params << struct_.additional_attributes
	}

	for param in params {
		body = "\tencoded := json.encode(${param.name})\n\t${b.actor_name}_client.edit_attribute('${param.name}', encoded)!"
		minor_edit, minor_edit_imports := make_function(
			name: 'edit_${param.name}'
			receiver: Param{
				name: '${b.actor_name}_client'
				data_type: '${b.actor_name.capitalize()}Client'
			}
			inputs: [param]
			public: true
			body: body
			type_: .result
		)
		str += "\n\n" + minor_edit
		imports.add_many(minor_edit_imports)
	}

	return Chunk{str, imports}
}

pub fn (mut b ActorBuilder) delete_client() !Chunk {

	mut body, mut imports := send_receive_job([], [], b.actor_name, 'delete')!

	str, func_imports := make_function(
		name: 'delete'
		receiver: Param{
			name: '${b.actor_name}_client'
			data_type: '${b.actor_name.capitalize()}Client'
		}
		public: false
		body: body
		type_: .result
	)
	imports.add_many(func_imports)

	return Chunk{str, imports}
}


pub fn (mut b ActorBuilder) get_all_client() !Chunk {

	receiver := Param{name: '${b.actor_name}_client', data_type: '${b.actor_name.capitalize()}Client'}
	output := Param{name: '${b.actor_name}s', data_type: '[]IModel${b.actor_name.capitalize()}', src_module:Module{name:'${b.actors_root}.${b.actor_name}.${b.actor_name}_model'}}

	body := "mut supervisor := supervisor_client.new() or {
	return error('Failed to create a new supervisor client with error: \\n\$err')
}
address_book := supervisor.get_address_book('${b.actor_name}')!
mut ${output.name} := ${output.data_type}\{\}
for _, address in address_book {
	if address != ${receiver.name}.${b.actor_name}_address {
		mut check_client := ${b.actor_name.capitalize()}Client{
			${b.actor_name}_address: address
			baobab: baobab_client.new('0')!
		}
		${output.name} << check_client.get() or {return error('Failed to get ${b.actor_name} instance with ${b.actor_name} client with error: \\n\$err')}
	}

}
return ${output.name}"

	str, mut imports := make_function(
		name: 'get_all'
		receiver: receiver
		outputs: [output]
		public: false
		body: indent(body, 1)
		type_: .result
	)
	imports.add_many([Module{name: '${b.actors_root}.supervisor.supervisor_client'}, Module{name: 'freeflowuniverse.baobab.client', alias: 'baobab_client'}])

	return Chunk{str, imports}
}

pub fn (mut b ActorBuilder) search_attribute_client() !Chunk {
	mut imports := []Module{}
	mut full_str := ''
	mut params := b.model.core_attributes.clone()
	for struct_ in b.model.structs {
		params << struct_.additional_attributes
	}
	for param in params {
		receiver := Param{name: '${b.actor_name}_client', data_type: '${b.actor_name.capitalize()}Client'}
		output := Param{name: 'matching_${b.actor_name}s', data_type: '[]string', src_module:Module{name:'${b.actors_root}.${b.actor_name}.${b.actor_name}_model'}}
		input := param

		body := "mut supervisor := supervisor_client.new() or {
	return error('Failed to create a new supervisor client with error: \$err')
}
address_book := supervisor.get_address_book('${b.actor_name}')!
mut ${output.name} := []string{}
for actor_id, address in address_book {
	mut check_client := ${b.actor_name.capitalize()}Client{
		${b.actor_name}_address: address
		baobab: baobab_client.new('0')!
	}
	check_value := check_client.get_${input.name}()!
	if ${input.name} == check_value { matching_users << actor_id }
}
return matching_users"

		str, func_imports := make_function(
			name: 'search_${param.name}'
			receiver: receiver
			outputs: [output]
			inputs: [input]
			public: false
			body: indent(body, 1)
			type_: .result
		)
		imports.add_many(func_imports, [Module{name: '${b.actors_root}.supervisor.supervisor_client'}, Module{name: 'freeflowuniverse.baobab.client', alias: 'baobab_client'}])
		full_str += '\n\n${str}'
	}

	return Chunk{full_str, imports}
}