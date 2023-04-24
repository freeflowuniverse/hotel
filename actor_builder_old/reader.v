module actor_builder_old

import v.ast
import freeflowuniverse.crystallib.pathlib
import v.parser
import v.pref

const (
	fpref = &pref.Preferences{
		is_fmt: true
	}
)

// This function simply gets the different structs from the model/model.v file. It should also check to make sure the model is valid
fn (mut b Builder) read_model () ! {

	// Accesses all the relevant file and parses it using v.ast
	model_path := b.dir_path.join('model/model.v')!
	model_file, table := read_file(model_path)

	// Gets all the declared structs from the parsed file
	mut structs := []ast.StructDecl{}
	for stmt in model_file.stmts {
		if stmt is ast.StructDecl {
			structs << stmt
		}
	}

	if structs.len == 0 {
		return error("No structs have been defined in your model.v file. Please ensure that you have defined your actor model there.")
	}

	// Identifies the core struct which forms the basis of all relevant actor flavors and interfaces. Then parses this data into core_struct_attrs
	core_candidates := structs.filter(it.name.to_lower().contains('core'))
	if core_candidates.len != 1 {
		return error("There should only be one struct in your model.v file that contains the name 'Core', please ensure that this is the case!")
	}
	core_struct := core_candidates[0]
	
	for field in core_struct.fields {
		data_type, import_string := b.parse_type(table.type_str(field.typ), model_file.imports, 'model') or {return error("Failed to parse type with error: $err")}
		b.core_struct_attrs[field.name] = data_type
		if import_string !in b.core_struct_imports {
			b.core_struct_imports << import_string
		}
		
	}

	// Identifies all structs that embed the core struct and passes their names into instance_flavors
	for struct_decl in structs {
		for embed in struct_decl.embeds {
			if table.type_str(embed.typ) == core_struct.name {
				b.instance_flavors << struct_decl.name
			}
		}
	}

}

// This function reads the methods from the method file, identifying both inputs and outputs
fn (mut b Builder) read_methods () ! {
	methods_path := b.dir_path.join('methods.v')!
	methods_file, table := read_file(methods_path)

	// Identifies all method declarations in the file
	mut method_decls := []ast.FnDecl{}
	for stmt in methods_file.stmts {
		if stmt is ast.FnDecl {
			if stmt.is_pub == true {
				method_decls << stmt
			}
		}
	}

	// For each declaration, the inputs and outputs are identified and cleaned up
	for decl in method_decls.filter(it.is_method == true) {
		mut new_method := Method{
			name: decl.name
		}
		mut count := 0
		for param in decl.params[1..] {
			mut raw_type_str := table.type_str(param.typ)
			data_type, import_stmt := b.parse_type(raw_type_str, methods_file.imports, b.actor_name) or {return error("Failed to parse type with error: $err")}
			new_method.inputs[count] = Data{
				name: param.name
				data_type: data_type
				import_stmt: import_stmt
			}
			count += 1
		}

		count = 0
		for return_type in table.type_str(decl.return_type).trim('()').split(',') { 
			data_type, import_stmt := b.parse_type(return_type.trim_space(), methods_file.imports, b.actor_name) or {return error("Failed to parse type with error: $err")}
			if data_type != 'void' {
				new_method.outputs[count] = Data{
					name: generate_name(data_type)
					data_type: data_type
					import_stmt: import_stmt
				}
				count += 1
			}
			
		}

		// todo this isnt a true solution and will need to be fixed
		if new_method.name != 'get' {
			b.actor_methods << new_method
		}
		
	}
}

// UTILITY FUNCTIONS

fn read_file(file_path pathlib.Path) (&ast.File, &ast.Table) {
	table := ast.new_table()
	file_ast := parser.parse_file(file_path.path, table, .parse_comments, actor_builder_old.fpref)
	return file_ast, table
}

// todo check for sum type and get sum type
fn (b Builder) parse_type(type_name_ string, imports []ast.Import, source_file_name string) !(string, string) {
	mut type_name := type_name_
	mut prefix := ''	
	if type_name.contains('&') {
		prefix += '&'
		type_name = type_name.all_after_last('&')
	}
	if type_name.contains(']') {
		prefix += "${type_name.all_before_last(']')}]"
		type_name = type_name.all_after_last(']')
	}

	mut required_import := ''
	mut short_type := type_name
	if type_name.contains('.') {
		chunks := type_name.split('.')
		short_type = "$prefix${chunks#[-2..].join('.')}"
		module_name := type_name.all_before_last('.').all_after_last('.')
		for import_ in imports {
			if module_name == import_.alias {
				required_import = import_.mod
				return short_type, required_import
			}
		}

		if module_name != source_file_name {
			println(module_name)
			println(b.actor_name)
			return error("Please check your types, '$type_name' seems like it is imported, but is not!")
		}
	}

	return short_type, required_import
}

fn generate_name(data_type string) string {
	mut remaining_list := [data_type]
	mut name_parts := identify_feature(mut remaining_list)

	if name_parts.last().contains('.') {
		name_parts[name_parts.len-1] = name_parts.last().split('.').last().to_lower()
	}

	return name_parts.reverse().join('_') // ? should I use reverse here?
}

fn identify_feature (mut remaining_list []string) []string {
	mut remaining := remaining_list.last()
	match true {
		remaining.starts_with('&') {
			remaining_list.delete_last()
			remaining_list << ['reference', remaining.all_after('&')]
			remaining_list = identify_feature(mut remaining_list)
		}
		remaining.starts_with('[]') {
			remaining_list.delete_last()
			remaining_list << ['list', remaining.all_after(']')]
			remaining_list = identify_feature(mut remaining_list)
		}
		remaining.starts_with('map[') {
			remaining_list.delete_last()
			remaining_list << ['map', remaining.all_after(']')]
			remaining_list = identify_feature(mut remaining_list)
		}
		else {}
	}
	return remaining_list
}

