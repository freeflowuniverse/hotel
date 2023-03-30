import freeflowuniverse.hotel.client_builder
import os

// Not an isolated example but references the kitchen actor of the hotel
const source = os.dir(@FILE) + '/../../new/kitchen'

fn main() {
	mut b := client_builder.new()
	b.read_actor_dir(source)!
	// println(b)
	file_dest := '${os.dir(@FILE)}/${b.actor_name}_client.v'
	b.write_client(file_dest)!
}
