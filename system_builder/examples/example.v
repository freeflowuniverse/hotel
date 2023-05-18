import system_builder
import os

fn main () {

	dir_path := os.dir(@FILE)

	mut system := system_builder.new(
		src_path: dir_path + '/src_actors'
		dest_path: dir_path + '/actors'
		actors_root: 'freeflowuniverse.hotel.system_builder.examples.actors'
		actors: ['kitchen', 'user']
	)!

	system.build()!
}
