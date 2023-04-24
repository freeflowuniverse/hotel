module main

import freeflowuniverse.hotel.actor_builder_old
import os

fn main() {
	dir_path := os.dir(@FILE) + '/kitchen'
	mut builder := actor_builder_old.new(dir_path) or { panic("Failed to generate a new builder with error: $err") }
	builder.build() or { panic("Failed to execute build with error: $err") }
}