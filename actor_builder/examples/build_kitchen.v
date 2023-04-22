module main

import freeflowuniverse.hotel.actor_builder
import os

fn main() {
	dir_path := os.dir(@FILE) + '/kitchen'
	mut builder := actor_builder.new(dir_path) or { panic("Failed to generate a new builder with error: $err") }
	builder.build() or { panic("Failed to execute build with error: $err") }
}