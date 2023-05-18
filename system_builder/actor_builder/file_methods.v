module actor_builder

import v.ast

fn (mut b ActorBuilder) parse_update_methods() ! {
	mut methods_file := File{
		path: b.dir_path.extend_file('methods.v')!
	}
	file, table := parse_file(methods_file.path)
	b.parse_methods(file, table) or {
		return error('Failed to read methods.v file with error:\n ${err}')
	}
	b.init_standard_methods(Module{ name: file.mod.name })
	methods_file.add( make_object("I${b.actor_name.capitalize()}", b.model.core_attributes, true, true) )
	methods_file.add( b.get_methods() )
	methods_file.add( b.get_attribute_methods() )
	methods_file.add( b.edit_attribute_methods() )
	methods_file.imports.deduct_many(file.imports.map(Module{name:it.mod, alias:it.alias}))
	append_create_file(mut methods_file.path, methods_file.content.join('\n\n'), methods_file.imports)!
}

fn (mut b ActorBuilder) parse_methods(file &ast.File, table &ast.Table) ! {
	for stmt in file.stmts {
		if stmt is ast.FnDecl {
			if stmt.is_pub == true {
				b.actor_methods << parse_custom_method(stmt, table, file, b.actor_name) or {
					return error('Failed to parse method with error: \n${err}')
				}
			}
		}
	}
}

fn (mut b ActorBuilder) init_standard_methods(src_module Module) {
	for method_name in ['get', 'get_attribute', 'edit_attribute', 'delete'] {
		mut method := Method{
			actor_name: b.actor_name
			src_module: src_module
			name: method_name
			custom: false
		}
		method.inputs << match method_name {
			'get_attribute' {
				[Param{
					name: 'attribute_name'
					data_type: 'string'
				}, Param{
					name: 'encoded_value'
					data_type: 'string'
				}]
			}
			'edit_attribute' {
				[Param{
					name: 'attribute_name'
					data_type: 'string'
				}, Param{
					name: 'encoded_value'
					data_type: 'string'
				}]
			}
			else {
				[]Param{}
			}
		}
		method.outputs << match method_name {
			'get' {
				[
					Param{
						name: 'encoded_${b.actor_name}'
						data_type: 'string'
					},
				]
			}
			'get_attribute' {
				[Param{
					name: 'encoded_attribute'
					data_type: 'string'
				}]
			}
			else {
				[]Param{}
			}
		}
		b.actor_methods << method
	}
}

pub fn (mut b ActorBuilder) get_methods() Chunk {
	mut ifs := ''
	for model_struct in b.model.structs {
		ifs += "if i${b.actor_name} is ${model_struct.name} {\n\treturn json.encode(i${b.actor_name})\n} else "
	}
	ifs = ifs.trim_right(' else ')
	body := 
"${indent(ifs, 1)}
	panic('This point should never be reached. There is an issue with the code!')"

	get_method := b.actor_methods.filter(it.name == "get")[0]
	methods_str, mut imports := make_function(
		name: "get"
		receiver: Param{
			name: "i${b.actor_name}"
			data_type: "I${b.actor_name.capitalize()}"
		}
		inputs: get_method.inputs
		outputs: get_method.outputs
		public: true
		body: body
		type_: .result
	)
	imports.add(b.model.structs[0].src_module)

	return Chunk{methods_str, imports}
}

pub fn (mut b ActorBuilder) get_attribute_methods() Chunk {

	encode := fn [b] (params []Param) string {
		return params.map("'${it.name}' \{ return json.encode(i${b.actor_name}.${it.name}) \}").join_lines()
	}

	mut flavor_branches := []string{}

	for struct_ in b.model.structs {
		if struct_.additional_attributes.len != 0 {
			flavor_branches << 
"if i${b.actor_name} is ${struct_.name} \{
\tmatch attribute_name \{
${indent(encode(struct_.additional_attributes), 2)}
\t\telse { return error(\"Attribute name '\$attribute_name' is not recognised by this user instance!\") }
	\}
\}"
		}
	}

	body := 
"match attribute_name \{
${indent(encode(b.model.core_attributes), 1)}
	else \{
${indent(flavor_branches.join_lines(), 2)}
		return error(\"Attribute name '\${attribute_name}' not recognised by this user instance!\")
	\}
\}"

	get_attribute_method := b.actor_methods.filter(it.name == "get_attribute")[0]

	methods_str, mut imports := make_function(
		name: "get_attribute"
		receiver: Param{
			name: "i${b.actor_name}"
			data_type: "I${b.actor_name.capitalize()}"
		}
		inputs: get_attribute_method.inputs
		outputs: get_attribute_method.outputs
		public: true
		body: indent(body, 1)
		type_: .result
	)
	imports.add(Module{name: "json"})

	return Chunk{methods_str, imports}
}

pub fn (mut b ActorBuilder) edit_attribute_methods() Chunk {
	decode := fn [b] (params []Param) string {
		mut lines := []string{}
		for param in params {
			mut line := "'${param.name}' { i${b.actor_name}.${param.name} = "
			if param.data_type.contains_any('.[]') { // TODO check if this is comprehensive
				line += 'json.decode(${param.data_type}, encoded_value)! }'
			} else if param.data_type == 'string' {
				line += 'encoded_value.trim(\'"\').trim("\'") }'
			} else {
				line += 'encoded_value.${param.data_type}() }'
			}	
			lines << line	
		}
		return lines.join_lines()
	}

	mut flavor_branches := []string{}

	for struct_ in b.model.structs {
		if struct_.additional_attributes.len != 0 {
			flavor_branches << 
"if i${b.actor_name} is ${struct_.name} \{
\tmatch attribute_name \{
${indent(decode(struct_.additional_attributes), 2)}
\t\telse { return error(\"Attribute name '\$attribute_name' is not recognised by this user instance!\") }
	\}
\}"
		}
	}

	body := 
"match attribute_name \{
${indent(decode(b.model.core_attributes), 1)}
	else \{
${indent(flavor_branches.join_lines(), 2)}
		return error(\"Attribute name '\${attribute_name}' not recognised by this user instance!\")
	\}
\}"

	edit_attribute_method := b.actor_methods.filter(it.name == "edit_attribute")[0]

	methods_str, mut imports := make_function(
		name: "edit_attribute"
		receiver: Param{
			name: "i${b.actor_name}"
			data_type: "I${b.actor_name.capitalize()}"
		}
		inputs: edit_attribute_method.inputs
		outputs: edit_attribute_method.outputs
		public: true
		body: indent(body, 1)
		type_: .result
	)
	imports.add(Module{name: "json"})

	return Chunk{methods_str, imports}
}




// pub fn (mut iuser IUser) edit_attribute (attribute_name string, encoded_value string) ! {
// 	mut userclient := user_client.new(iuser.id)!
// 	match attribute_name {
// 		'telegram_username' {
// 			ids := userclient.check_all('telegram_username', iuser.telegram_username)!
// 			if ids.len > 0 {
// 				return error("This attribute should be unique, however it already exists in User ${ids[0]}!")
// 			}
// 			iuser.telegram_username = encoded_value.trim("'").trim('"')
// 		}
// 		'id' {
// 			ids := userclient.check_all('id', iuser.id)!
// 			if ids.len > 0 {
// 				return error("This attribute should be unique, however it already exists in User ${ids[0]}!")
// 			}
// 			iuser.id = encoded_value.trim("'").trim('"')
// 		}
// 		'firstname' { iuser.firstname = encoded_value.trim("'").trim('"') }
// 		'lastname' { iuser.lastname = encoded_value.trim("'").trim('"') }
// 		'email' {
// 			ids := userclient.check_all('email', iuser.email)!
// 			if ids.len > 0 {
// 				return error("This attribute should be unique, however it already exists in User ${ids[0]}!")
// 			}
// 			iuser.email = encoded_value.trim("'").trim('"')
// 		}
// 		'phone_number' {
// 			ids := userclient.check_all('phone_number', iuser.phone_number)!
// 			if ids.len > 0 {
// 				return error("This attribute should be unique, however it already exists in User ${ids[0]}!")
// 			}
// 			iuser.phone_number = encoded_value.trim("'").trim('"')
// 		}
// 		'date_of_birth' { iuser.date_of_birth = json.decode(time.Time, encoded_value)! }
// 		'allergies' { iuser.allergies = json.decode([]string, encoded_value)! }
// 		'preferred_contact' { iuser.preferred_contact = encoded_value.trim("'").trim('"') }
// 		'digital_funds' { iuser.digital_funds = encoded_value.f64() }
// 		else {
// 			if mut iuser is user_model.Employee {
// 				match attribute_name{
// 					'title' { iuser.title = encoded_value.trim("'").trim('"') }
// 					'actor_names' { iuser.actor_names = json.decode([]string, encoded_value)! }
// 					'shifts' { iuser.shifts = json.decode([]user_model.Shift, encoded_value)! }
// 					'working' { iuser.working = encoded_value.bool() }
// 					'remaining_holidays' { iuser.holidays_remaining = encoded_value.int() }
// 					else {
// 						return error("Attribute name '$attribute_name' not recognised by this user instance!")
// 					}
// 				}
// 			}
// 			return error("Attribute name '$attribute_name' not recognised by this user instance!")
// 		}
// 	}
// }
