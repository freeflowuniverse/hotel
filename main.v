import system_builder
import outputs

fn main () {

	dir_path := os.dir(@FILE)

	system := system_builder.new(
		src_path: dir_path + '/src/actors'
		dest_path: dir_path + '/actors'
		actors_root: 'freeflowuniverse.hotel.actors'
		actors: ['kitchen', 'user']
	)!

	system.build()!
}
