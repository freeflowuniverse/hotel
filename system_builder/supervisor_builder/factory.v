module supervisor_builder 

import freeflowuniverse.crystallib.pathlib

import os

pub struct SupervisorBuilder {
pub mut:
	actors []Actor
	dir_path pathlib.Path
	actors_root string
}

pub struct Actor {
pub mut:
	name string
	flavors []string
}

pub fn new_supervisor (dir_path pathlib.Path, actors_root string) !SupervisorBuilder {
	if dir_path.exist != .yes {
		os.mkdir(dir_path.path)!
		dir_path.check()
	} else if dir_path.cat != .dir {
		return error('The file path does not lead to a directory! Ensure that the actor directory path, rather any file, is passed into this function')
	}
	return SupervisorBuilder{
		dir_path: dir_path
		actors_root: actors_root
	}
}

pub fn (mut sb SupervisorBuilder) add (actor Actor) {
	sb.actors << actor
}

pub fn (mut sb SupervisorBuilder) build() ! {
	sb.create_model()!
	sb.create_methods()!
	sb.create_actor()!
	sb.create_client()!
}