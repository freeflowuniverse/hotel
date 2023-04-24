module actor_builder

import freeflowuniverse.crystallib.pathlib

pub fn new (actor_dir_path string) !Builder {
	mut dir_path := pathlib.get(actor_dir_path)
	if dir_path.exist != .yes {
		return error("Nothing exists at the file path destination!")
	} else if dir_path.cat != .dir {
		return error("The file path does not lead to a directory! Ensure that the actor directory path, rather any file, is passed into this function")
	}

	actor_name := dir_path.name_no_ext()

	mut sub_list := dir_path.file_list(pathlib.ListArgs{recursive: true}) or {return error("Failed to list files within the directory with error: $err")}
	mut file_names := []string{} // TODO change to a map
	for mut file_entry in sub_list {
		file_names << file_entry.name()
	}
	for file_name in ['methods.v', 'model.v'] {
		if file_names.contains(file_name) == false {
			return error("This directory must have a file named '$file_name'!")		
		}
	}

	return Builder{
		dir_path: dir_path
		actor_name: actor_name
	}
}

pub fn (mut b Builder) build () ! {
	b.parse_update_model() or {return error("Failed to read ${b.actor_name}/model/model.v with error: \n$err")}
	b.parse_update_methods() or {return error("Failed to read ${b.actor_name}/methods.v with error: \n$err")}
	b.write_actor() or {return error("Failed to write actor to ${b.actor_name}/actor.v with error: \n$err")}
	b.write_client() or {return error("Failed to write client to ${b.actor_name}/client.v with error: \n$err")}
	println(b)
}



