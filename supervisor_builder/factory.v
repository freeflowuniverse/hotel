module supervisor_builder 

import os

pub struct SupervisorBuilder {
	actors []Actor
	dir_path pathlib.Path
	actors_root string
}

pub struct Actor {
	name string
	flavors []string
}

fn new_supervisor (actors []Actor, supervisor_dir_path string, actors_root string) ! {
	mut dir_path := pathlib.get(supervisor_dir_path)
	if dir_path.exist != .yes {
		os.mkdir(dir_path)!
	} else if dir_path.cat != .dir {
		return error('The file path does not lead to a directory! Ensure that the actor directory path, rather any file, is passed into this function')
	}
	return SupervisorBuilder{
		actors: actors
		dir_path: dir_path
		actors_root: actors_root
	}
}

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

pub fn (mut sb SupervisorBuilder) build() ! {
	sb.create_model()!
	sb.create_methods()!
	sb.create_actor()!
	sb.create_client()!
}