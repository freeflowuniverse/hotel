module system_builder

import freeflowuniverse.hotel.system_builder.actor_builder
import freeflowuniverse.hotel.system_builder.supervisor_builder
import freeflowuniverse.crystallib.pathlib
import os

pub struct SystemBuilder {
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

pub fn new (p NewSystemParams) ! {

	src_path := pathlib.get(p.src_path)
	dest_path := pathlib.get(p.src_path)

	if src_path.exists == false {
		return error("Please ensure that src_path refers to an existing directory!")
	}

	if dest_path.name() != 'actors' {
		return error("Please ensure that dest_path refers to a directory with the name 'actors'!")
	} 

	if dest_path.exists() == true {
		os.rmdir_all(dest_path.path)!
	}
	os.mkdir(dest_path.path)!

	mut sys := System{
		src_path: p.src_path
		dest_path: p.dest_path
		actors_root: p.actors_root
	}
	for actor in p.actors {
		actor_dest_path := sys.dest_path.extend_dir('actor')
		os.mkdir(actor_dest_path.path)!

		actor_src_path := sys.src_path.extend_dir('actor')
		if actor_src_path.exists() == false {
			return error("Please make sure that you have provided a source directory for the actor '$actor' and that it is populated!")
		}

		os.cp_all(actor_src_path.path, actor_dest_path.path, true) or { return error("Failed to copy src directory of actor over to destination directory") }

		actor_dir_path := sys.dest_path.extend_dir(actor)
		sys.actors << actor_builder.new_actor(actor_dir_path, actors_root) or { panic("Failed to generate a new builder for actor '${actor}' with error: $err") }
	}

	supervisor_dir_path := sys.dest_path.extend_dir('supervisor')
	sys.supervisor = supervisor_builder.new_supervisor(supervisor_dir_path, actors_root)!
}

fn (mut sys SystemBuilder) build () ! {
	for actor in sys.actors {
		actor.build() or { return error("Failed to build actor '${actor.actor_name}' with error: \n$err")}
		
		sys.supervisor.add(
			name: actor.actor_name
			flavors: actor.model.structs.map(it.name)
		)
	}
	sb.build()!
}


