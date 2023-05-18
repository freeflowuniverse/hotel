module actor_builder

import freeflowuniverse.crystallib.pathlib
import v.ast

// Reads the model.v file, creates an interface and writes it
fn (mut b ActorBuilder) parse_update_model() ! {
	mut model_file := File{
		path: b.dir_path.extend_file('${b.actor_name}_model/model.v')!
	}
	b.parse_model(model_file.path) or {
		return error('Failed to read model.v file with error:\n ${err}')
	}
	model_file.add(make_object('IModel${b.actor_name.capitalize()}', b.model.core_attributes,
		true, true))

	append_create_file(mut model_file.path, model_file.content.join_lines(), [])!
}

// This function simply gets the different structs from the ACTOR_model/model.v file. It should also check to make sure the model is valid
fn (mut b ActorBuilder) parse_model(model_path pathlib.Path) ! {
	model_file, table := parse_file(model_path)
	// Gets all the declared structs from the parsed file
	mut structs := []ast.StructDecl{}
	for stmt in model_file.stmts {
		if stmt is ast.StructDecl {
			structs << stmt
		}
	}

	if structs.len == 0 {
		return error('No structs have been defined in your model.v file. Please ensure that you have defined your actor model there.')
	}

	// Identifies the core struct which forms the basis of all relevant actor flavors and interfaces. Then parses this data into core_struct_attrs
	core_candidates := structs.filter(it.name.to_lower().contains('core'))
	if core_candidates.len != 1 {
		return error("There should only be one struct in your model.v file that contains the name 'Core', please ensure that this is the case!")
	}
	core_struct_decl := core_candidates[0]

	core_struct := parse_struct(core_struct_decl, table, model_file, "${b.actors_root}.${b.actor_name}.${b.actor_name}_model") or {
		return error('Failed to parse struct with error:\n ${err}')
	}
	b.model.core_attributes << core_struct.additional_attributes
	// Identifies all structs that embed the core struct and passes their names into instance_flavors
	for struct_decl in structs {
		for embed in struct_decl.embeds {
			if table.type_str(embed.typ) == core_struct.name {
				mut struct_ := parse_struct(struct_decl, table, model_file, "${b.actors_root}.${b.actor_name}.${b.actor_name}_model") or {
					return error('Failed to parse struct with error:\n ${err}')
				}
				struct_.src_module = Module{name: '${b.actors_root}.${b.actor_name}.${b.actor_name}_model'}
				b.model.structs << struct_
			}
		}
	}
}
