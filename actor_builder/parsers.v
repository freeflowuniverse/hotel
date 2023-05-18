module actor_builder

import freeflowuniverse.crystallib.pathlib
import v.parser
import v.pref
import v.ast

fn parse_file(file_path pathlib.Path) (&ast.File, &ast.Table) {
	fpref := &pref.Preferences{
		is_fmt: true
	}
	table := ast.new_table()
	file_ast := parser.parse_file(file_path.path, table, .parse_comments, fpref)
	return file_ast, table
}

fn parse_struct(struct_decl ast.StructDecl, table &ast.Table, file &ast.File, import_root string) !Struct {
	mut new_struct := Struct{
		name: struct_decl.name
	}
	for field in struct_decl.fields {
		mut param := parse_nameless_param(table.type_str(field.typ), table, file) or {
			return error('Failed to parse type with error: ${err}')
		}
		if param.data_type == import_root.all_after_last(".") {
			param.data_type = import_root
		}
		param.name = field.name
		new_struct.additional_attributes << param
	}
	return new_struct
}

fn parse_nameless_param(type_string string, table &ast.Table, file &ast.File) !Param {
	mut type_name := type_string
	// Trims and stores any reference, list, or map identification from the beginning of the string
	mut prefix := ''
	if type_name.contains('&') {
		prefix += '&'
		type_name = type_name.all_after_last('&')
	}
	if type_name.contains(']') {
		prefix += '${type_name.all_before_last(']')}]'
		type_name = type_name.all_after_last(']')
	}

	// if the type name contains a '.' ie if it is a custom (not integer, string) type, then it is parsed
	mut mod := Module{}
	mut short_type := type_name
	if type_name.contains('.') {
		chunks := type_name.split('.')
		short_type = '${prefix}${chunks#[-2..].join('.')}'
		module_name := type_name.all_before_last('.').all_after_last('.')
		for import_ in file.imports {
			if module_name == import_.mod.all_after_last('.') {
				mod.name = import_.mod
				if import_.mod.all_after_last('.') != import_.alias {
					mod.alias = import_.alias
				}
			}
		}

		if module_name == file.mod.short_name { // todo check whether this should be short_name or name
			mod.name = file.mod.name
		}

		if mod.name == '' {
			return error("Please check your types, '${type_name}' seems like it is imported, but is not!")
		}

		return Param{
			data_type: short_type
			src_module: mod
		}
	} else {
		return Param{
			data_type: prefix + short_type
		}
	}
}

fn parse_custom_method(fn_decl ast.FnDecl, table &ast.Table, file &ast.File, actor_name string) !Method {
	mut new_method := Method{
		name: fn_decl.name
		actor_name: actor_name
		src_module: Module{
			name: file.mod.name
		}
		custom: true
	}
	for ast_param in fn_decl.params[1..] {
		mut param := parse_nameless_param(table.type_str(ast_param.typ), table, file) or {
			return error('Failed to parse type with error: ${err}')
		}
		param.name = ast_param.name
		new_method.inputs << param
	}

	for return_type in table.type_str(fn_decl.return_type).trim('()').split(',') {
		mut param := parse_nameless_param(return_type.trim_space(), table, file) or {
			return error('Failed to parse type with error: ${err}')
		}
		if param.data_type != 'void' {
			param.name = generate_name(param.data_type)
			new_method.outputs << param
		}
	}
	return new_method
}

fn generate_name(data_type string) string {
	mut remaining_list := [data_type]
	mut name_parts := identify_feature(mut remaining_list)

	if name_parts.last().contains('.') {
		name_parts[name_parts.len - 1] = name_parts.last().split('.').last().to_lower()
	}

	return name_parts.reverse().join('_')
}

fn identify_feature(mut remaining_list []string) []string {
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
