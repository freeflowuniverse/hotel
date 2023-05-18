module actor_builder

import freeflowuniverse.crystallib.pathlib

// TODO mutable params for functions specifically for when there is an ActionJob input

pub fn new_actor (actor_dir_path string, actors_import_root string) !Builder {
	mut dir_path := pathlib.get(actor_dir_path)
	if dir_path.exist != .yes {
		return error('Nothing exists at the file path destination!')
	} else if dir_path.cat != .dir {
		return error('The file path does not lead to a directory! Ensure that the actor directory path, rather any file, is passed into this function')
	}

	actor_name := dir_path.name_no_ext()

	args := pathlib.ListArgs{
		recursive: true
	}
	mut sub_list := dir_path.file_list(args) or {
		return error('Failed to list files within the directory with error: ${err}')
	}
	mut file_names := []string{} // TODO change to a map
	for mut file_entry in sub_list {
		file_names << file_entry.name()
	}
	for file_name in ['methods.v', 'model.v'] {
		if file_names.contains(file_name) == false {
			return error("This directory must have a file named '${file_name}'!")
		}
	}

	return Builder{
		dir_path: dir_path
		actor_name: actor_name
		actors_root: actors_import_root
	}
}

pub fn (mut b Builder) build() ! {
	b.parse_update_model()!
	b.parse_update_methods()!
	b.create_actor()!
	b.create_client()!
}