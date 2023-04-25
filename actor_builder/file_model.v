module actor_builder

import freeflowuniverse.crystallib.pathlib

import v.ast
import os


fn (mut b Builder) parse_update_model () ! {
	// Accesses all the relevant file and parses it using v.ast
	model_path := b.dir_path.join('${b.actor_name}_model/model.v')!
	model_file, table := parse_file(model_path)
	mut file_lines := os.read_lines(model_path.path) or {return error("Failed to read model.v file with error: \n$err")}

	code_gen_line := '// +++++++++ CODE GENERATION BEGINS BELOW +++++++++'
	if file_lines.any(it == code_gen_line) {
		index := file_lines.index(code_gen_line) 
		file_lines.delete_many(index, file_lines.len-index)
	}
	file_lines << [code_gen_line, '']

	b.parse_model(model_path, model_file, table) or {return error("Failed to read model.v file with error:\n $err")}
	b.update_model(model_path, mut file_lines) or {return error("Failed to update model.v file with error:\n $err")}
}


// This function simply gets the different structs from the ACTOR_model/model.v file. It should also check to make sure the model is valid
fn (mut b Builder) parse_model (model_path pathlib.Path, model_file &ast.File, table &ast.Table) ! {
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
	
	b.parse_struct_to_interface(core_struct, table, model_file) or {return error("Failed to parse struct to interface with error:\n $err")}

	// Identifies all structs that embed the core struct and passes their names into instance_flavors
	for struct_decl in structs {
		for embed in struct_decl.embeds {
			if table.type_str(embed.typ) == core_struct.name {
				b.core_interface.flavors << struct_decl.name
			}
		}
	}
}


fn (b Builder) update_model (model_path pathlib.Path, mut file_lines []string) ! {
	inter_str, _ := b.write_interface(b.core_interface, 'model')
	// It is not necessary to get imports in this case because by definition all necessary imports are already imported

	file_lines << inter_str
	file_str := file_lines.join_lines()
	os.write_file(model_path.path, file_str) or {return error("Failed to write to model.v file with error: \n$err")}
}
