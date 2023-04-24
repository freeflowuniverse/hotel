module actor_builder

import os

import v.ast
import freeflowuniverse.crystallib.pathlib

fn (mut b Builder) parse_update_methods () ! {
	// Accesses all the relevant file and parses it using v.ast
	methods_path := b.dir_path.join('methods.v')!

	mut file_lines := os.read_lines(methods_path.path) or {return error("Failed to read methods.v file with error: \n$err")}
	code_gen_line := '// +++++++++ CODE GENERATION BEGINS BELOW +++++++++'
	if file_lines.any(it == code_gen_line) {
		index := file_lines.index(code_gen_line) 
		file_lines.delete_many(index, file_lines.len-index)
	}
	file_lines << [code_gen_line, '']

	methods_file, table := parse_file(methods_path)
	b.parse_methods(methods_file, table) or {return error("Failed to read methods.v file with error:\n $err")}
	b.actor_methods = b.actor_methods.filter(it.name!='get') // TODO find a better way to fix this

	b.init_standard_methods(
		name: methods_file.mod.name
	)

	b.update_methods(methods_path, mut file_lines, methods_file) or {return error("Failed to update methods.v file with error:\n $err")}
}


fn (mut b Builder) parse_methods (file &ast.File, table &ast.Table) ! {
	for stmt in file.stmts {
		if stmt is ast.FnDecl {
			if stmt.is_pub == true {
				b.actor_methods << b.parse_method(stmt, table, file, 'custom') or {return error("Failed to parse method with error: \n$err")}
			}
		}
	}
}


fn (b Builder) update_methods (methods_path pathlib.Path, mut file_lines []string, methods_file &ast.File) ! {
	mut method_strs := []string{}
	mut imports := []Module{}

	for method in b.actor_methods {
		if method.method_type != .custom {
			method_str, new_imports := b.write_method(method, 'methods') or {return error("Failed to write method to 'methods.v' file with error: \n$err")}
			method_strs << method_str
			imports.add_many(new_imports)
		}
	}

	for fn_str in method_strs {
		file_lines << fn_str
	}

	interface_str, interface_imports := b.write_interface(b.core_interface, 'actor')
	file_lines << interface_str
	imports.add_many(interface_imports)

	for import_ in imports {
		if import_str := write_import(import_) {
			if file_lines.contains(import_str) == false {
				file_lines.insert(2, import_str)
			}
		}
	}

	file_str := file_lines.join_lines()

	os.write_file(methods_path.path, file_str) or {return error("Failed to write to model.v file with error: \n$err")}
}


