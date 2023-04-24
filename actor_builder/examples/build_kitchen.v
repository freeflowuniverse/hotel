import freeflowuniverse.hotel.actor_builder

import os

fn main() {
	dir_path := os.dir(@FILE) + '/kitchen'
	// file, table := read_file(dir_path + '/src/')
	mut builder := actor_builder.new(dir_path) or { panic("Failed to generate a new builder with error: $err") }
	builder.build() or { panic("Failed to execute build with error: $err") }
}

// fn read_file(file_path string) (&ast.File, &ast.Table) {
// 	fpref = &pref.Preferences{
// 		is_fmt: true
// 	}
// 	table := ast.new_table()
// 	file_ast := parser.parse_file(file_path.path, table, .parse_comments, fpref)
// 	return file_ast, table
// }