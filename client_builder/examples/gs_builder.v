import freeflowuniverse.hotel.client_builder
import os

const source = os.dir(@FILE) + '/gs_source.v'

fn main () {
	mut b := client_builder.new()
	b.read_spv_file(source)!
	b.write_file('examples/gs_client_result.v')!
}