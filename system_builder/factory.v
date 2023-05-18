module system_builder

import freeflowuniverse.hotel.system_builder.actor_builder
import freeflowuniverse.hotel.system_builder.supervisor_builder
import freeflowuniverse.crystallib.pathlib
import os

pub struct SystemBuilder {
pub mut:
	src_path pathlib.Path
	dest_path pathlib.Path
	actors_root string
	actors []actor_builder.ActorBuilder
	supervisor supervisor_builder.SupervisorBuilder
}

pub struct NewSystemParams {
	src_path string
	dest_path string
	actors_root string
	actors []string
}

pub fn new (p NewSystemParams) !SystemBuilder {

	mut src_path := pathlib.get(p.src_path)
	mut dest_path := pathlib.get(p.dest_path)

	if src_path.exists() == false {
		return error("Please ensure that src_path refers to an existing directory!")
	}

	if dest_path.name() != 'actors' {
		return error("Please ensure that dest_path refers to a directory with the name 'actors'!")
	} 

	if dest_path.exists() == true {
		os.rmdir_all(dest_path.path) or {return error("Failed to remove `${dest_path.path} with error: \n$err")}
	}
	os.mkdir(dest_path.path) or {return error("Failed to make directory at ${dest_path.path} with error: \n$err")}

	mut sys := SystemBuilder {
		src_path: src_path
		dest_path: dest_path
		actors_root: p.actors_root
	}
	for actor in p.actors {
		actor_dest_path := sys.dest_path.extend_dir_create(actor) or {return error("Failed to extend dest_path with error: \n$err")}

		mut actor_src_path := sys.src_path.extend_dir_create(actor) or {return error("Failed to extend src_path with error: \n$err")}
		if actor_src_path.exists() == false {
			return error("Please make sure that you have provided a source directory for the actor '$actor' and that it is populated!")
		}

		os.cp_all(actor_src_path.path, actor_dest_path.path, true) or { return error("Failed to copy src directory of actor over to destination directory") }

		sys.actors << actor_builder.new_actor(actor_dest_path, sys.actors_root) or { panic("Failed to generate a new builder for actor '${actor}' with error: $err") }
	}

	supervisor_dir_path := sys.dest_path.extend_dir_create('supervisor') or {return error("Failed to extend supervisor path with error: \n$err")}
	sys.supervisor = supervisor_builder.new_supervisor(supervisor_dir_path, sys.actors_root)  or {return error("Failed to create new supervisor with error: \n$err")}

	return sys
}

pub fn (mut sys SystemBuilder) build () ! {
	for mut actor in sys.actors {
		actor.build() or { return error("Failed to build actor '${actor.actor_name}' with error: \n$err")}
		
		sys.supervisor.add(
			name: actor.actor_name
			flavors: actor.model.structs.map(it.name)
		)
	}
	sys.supervisor.build() or {return error("Failed to build supervisor with error: \n$err")}
}


