module actor_builder

import freeflowuniverse.crystallib.pathlib

import v.parser
import v.pref
import v.ast

// UTILITY FUNCTIONS


fn parse_file (file_path pathlib.Path) (&ast.File, &ast.Table) {
	fpref := &pref.Preferences{
		is_fmt: true
	}
	table := ast.new_table()
	file_ast := parser.parse_file(file_path.path, table, .parse_comments, fpref)
	return file_ast, table
}


fn (mut b Builder) parse_method (fn_decl ast.FnDecl, table &ast.Table, file &ast.File, type_string string) !Method {
	
	method_type := match type_string {
		'get' {MethodType.get}
		else {MethodType.custom}
	}


	mut new_method := Method{
		name: fn_decl.name
		method_type: method_type
		src_module: Module{name: file.mod.name} 
	}

	mut count := 0
	for ast_param in fn_decl.params[1..] {
		mut param := b.parse_nameless_param(table.type_str(ast_param.typ), table, file) or {return error("Failed to parse type with error: $err")}
		param.name = ast_param.name
		new_method.inputs[count] = param
		count += 1
	}

	count = 0
	for return_type in table.type_str(fn_decl.return_type).trim('()').split(',') { 
		mut param := b.parse_nameless_param(return_type.trim_space(), table, file) or {return error("Failed to parse type with error: $err")}
		if param.data_type != 'void' {
			param.name = generate_name(param.data_type)
			new_method.outputs[count] = param
			count += 1
		}
	}
	return new_method
}


fn (mut b Builder) parse_struct_to_interface (struct_decl ast.StructDecl, table &ast.Table, file &ast.File) ! {
	for field in struct_decl.fields {
		mut param := b.parse_nameless_param(table.type_str(field.typ), table, file) or {return error("Failed to parse type with error: $err")}
		param.name = field.name
		b.core_interface.attrs << param
	}
}


fn (b Builder) parse_nameless_param (type_string string, table &ast.Table, file &ast.File) !Param {
	mut type_name := type_string
	// Trims and stores any reference, list, or map identification from the beginning of the string
	mut prefix := ''	
	if type_name.contains('&') {
		prefix += '&'
		type_name = type_name.all_after_last('&')
	}
	if type_name.contains(']') {
		prefix += "${type_name.all_before_last(']')}]"
		type_name = type_name.all_after_last(']')
	}

	// if the type name contains a '.' ie if it is a custom (not integer, string) type, then it is parsed
	mut mod := Module{}
	mut short_type := type_name
	if type_name.contains('.') {
		chunks := type_name.split('.')
		short_type = "$prefix${chunks#[-2..].join('.')}"
		module_name := type_name.all_before_last('.').all_after_last('.')
		for import_ in file.imports {
			if module_name == import_.alias {
				mod.alias = import_.alias
				mod.name = import_.mod
			}
		}

		if module_name == file.mod.short_name { // todo check whether this should be short_name or name
			mod.name = file.mod.name
			mod.alias = file.mod.name
		}
		if mod.name == '' {
			return error("Please check your types, '$type_name' seems like it is imported, but is not!")
		}

		return Param{
			data_type: short_type
			src_module: mod 
		}
	} else {
		return Param{
			data_type: short_type
		}	
	}
}


fn generate_name(data_type string) string {
	mut remaining_list := [data_type]
	mut name_parts := identify_feature(mut remaining_list)

	if name_parts.last().contains('.') {
		name_parts[name_parts.len-1] = name_parts.last().split('.').last().to_lower()
	}

	return name_parts.reverse().join('_')
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


fn parse_existing_imports (file &ast.File) []Module {
	mut imports := []Module{}
	for imp in file.imports {
		imports << Module{
			name: imp.mod
			alias: imp.alias
		}
	}
	return imports
}

fn (mut b Builder) init_standard_methods (src_module Module) {
	
	mut get_method := Method{
		name: 'get'
		src_module: src_module
		method_type: .get
	}
	get_method.inputs[0] = Param{
		name: '${b.actor_name}_id'
		data_type: 'string'
	}
	get_method.outputs[0] = Param{
		name: 'encoded_${b.actor_name}'
		data_type: 'string'
	}

	b.actor_methods << get_method
}
