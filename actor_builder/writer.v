module actor_builder

import os
import v.ast

fn (mut b Builder) create_methods () string {
	mut get_method := Method{
		name: 'get'
	}
	get_method.inputs[0] = Data{
		name: '${b.actor_name}_id'
		data_type: 'string'
	}
	get_method.outputs[0] = Data{
		name: 'encoded_${b.actor_name}'
		data_type: 'string'
	}
	b.actor_methods << get_method


	mut gs := ''
	gs += 'pub fn (${b.actor_name} I${b.actor_name.capitalize()}) get ('
	for _, input in get_method.inputs {
		gs += '${input.name} ${input.data_type}, '
	}
	gs = gs.trim_right(', ')
	gs += ') !'
	for _, output in get_method.outputs {
		gs += '${output.data_type}, '
	}
	gs = gs.trim_right(', ')
	gs += ' {\n    '
	for flavor in b.instance_flavors {
		gs += 'if kitchen is $flavor {\n\t\treturn json.encode(kitchen)\n\t} else '
	}
	gs = gs.trim_right(' else ')
	gs += '\n\tpanic("This point should never be reached. There is an issue with the code!")\n}'

	return gs
}

fn (mut b Builder) write_methods () ! {
	// read in the kitchen.v file and turn it into a string
	methods_path := b.dir_path.join('methods.v') or {return error("Failed to join 'methods.v' to path with error: $err")}
	methods_file, _ := read_file(methods_path)

	mut source_lines := os.read_lines(methods_path.path) or {return error("Failed to read file with error: $err")}

	mut import_stmt := 'freeflowuniverse' + b.dir_path.join('model')!.path.all_after('freeflowuniverse')
	import_stmt = import_stmt.replace('/', '.')

	// todo 
	// add in new fn decl (either by hand at the end or by adding a new FnDecl)
	// parse the table and file using fmt
	// write the data to a file use fmt.write()
	
	// ! It seems to me that this chunk of code is depreacated, but it might be best to keep it in just in case someone redefines the interface of get command
	for stmt in methods_file.stmts {
		if stmt is ast.FnDecl {
			if stmt.short_name == 'get' {
				pos := stmt.pos
				source_lines.delete_many(pos.line_nr, pos.last_line - pos.line_nr + 1)
				source_lines.insert(pos.line_nr, ['___'].repeat(pos.last_line - pos.line_nr + 1))
			}
		} else if stmt is ast.InterfaceDecl {
			if stmt.name.all_after_last('.') == 'I${b.actor_name.capitalize()}' {
				pos := stmt.pos
				source_lines.delete_many(pos.line_nr, pos.last_line - pos.line_nr + 1)
				source_lines.insert(pos.line_nr, ['___'].repeat(pos.last_line - pos.line_nr + 1))
			}
		}
	}

	if methods_file.imports.any(it.mod == import_stmt) == false {
		source_lines.insert(2, 'import $import_stmt')
	}

	code_gen_line := '// +++++++++ CODE GENERATION BEGINS BELOW +++++++++'
	if source_lines.any(it == code_gen_line) {
		index := source_lines.index(code_gen_line) 
		source_lines.delete_many(index, source_lines.len-index)
	}

	source_lines << code_gen_line
	
	mut fs := source_lines.join_lines()

	methods_addendum := b.create_methods()
	fs += '\n\n' + methods_addendum

	fs += '\n\npub interface I${b.actor_name.capitalize()} {\nmut:\n'
	for name, typ in b.core_struct_attrs {
		fs += '\t$name\t$typ\n'
	}
	fs += '}'

	os.write_file(b.dir_path.join('methods.v')!.path, fs) or {return error("Failed to write file with error: $err")}
}



fn (mut b Builder) write_actor () ! {
	mut import_stmts := ['import freeflowuniverse.baobab.jobs {ActionJob}', 'import freeflowuniverse.baobab.client as baobab_client']

	mut astr := ''
	astr += 'module $b.actor_name\n\n'

	astr += "${import_stmts[0]}\n\n"

	astr += "struct ${b.actor_name.capitalize()}Actor {\n"
	astr += "\tid\tstring\n"
	astr += "\t${b.actor_name}\tI${b.actor_name.capitalize()}\n"
	astr += "\tbaobab baobab_client.Client\n}\n\n"

	astr += 'fn (actor ${b.actor_name.capitalize()}Actor) run () {\n\n}\n\n' // todo fill out

	astr += 'fn (actor ${b.actor_name.capitalize()}Actor) execute (mut job ActionJob) ! {\n'

	// todo parse actionname from job

	astr += '\tmatch actionname {\n'

	for method in b.actor_methods {
		astr += "\t\t'$method.name' {\n"
		for _, input in method.inputs {
			if input.data_type.contains('.') {
				astr += "\t\t\t${input.name} := json.decode(${input.data_type}, job.args.get('${input.name}')!)\n"
			} else {
				astr += "\t\t\t${input.name} := job.args.get('${input.name}')!\n"
			}
			if import_stmts.any(it.contains(input.import_stmt)) == false {
				import_stmts << 'import ${input.import_stmt}'
			}
		}
		astr += "\t\t\t"
		if method.outputs.len > 0 {
			astr += "${method.outputs.values().map(it.name).join(', ')} := "
		}
		astr += "actor.${b.actor_name}.${method.name}(${method.inputs.values().map(it.name).join(', ')})\n"

		for _, output in method.outputs {
			mut value := output.name
			if output.data_type.contains('.') {
				value = 'json.encode(${output.name})'
			}
			astr += "\t\t\tjob.result.kwarg_add('$output.name', $value)\n"
			if import_stmts.any(it.contains(output.import_stmt)) == false {
				import_stmts << 'import ${output.import_stmt}'
			}
		}
		astr += '\t\t}\n'
	}

	astr = astr.replace(import_stmts[0], import_stmts.join_lines())

	astr += '\t\telse {job.state = .error}\n\t}\n}'

	os.write_file(b.dir_path.join('actor.v')!.path, astr) or {return error("Failed to write file with error: $err")}

}


pub fn (mut b Builder) write_client () ! {
	file_dest_path := b.dir_path.join('${b.actor_name}_client/${b.actor_name}_client.v')!
	$if debug { println("\tPerforming file structure preparation ...") }
	dir := os.dir(file_dest_path.path)
	if os.exists(dir) {
		os.rmdir_all(dir)!
	}
	os.mkdir(dir)!
	mut dest_file := os.create(file_dest_path.path) or {return error("Failed to create file: $err")}
	defer {
		dest_file.close()
	}
	$if debug { println("\tGenerating client string ...") }
	b.generate_client_text()
	$if debug { println("\tWriting client string ...\n") }
	dest_file.write_string(b.client_text)  or {return error("Failed to write client string to file: $err")}

	// todo use fmt on the produced file
}



pub fn (mut b Builder) generate_client_text () {
	mut str := ''

	// todo get command

	str += 'module ${b.actor_name}_client\n\n'
	str += 'import json\n\n'
	str += 'import freeflowuniverse.crystallib.params\n'
	str += 'import freeflowuniverse.baobab.client as baobab_client\n'
	str += 'import freeflowuniverse.hotel.actors.supervisor.supervisor_client\n'

	str += '\npub interface IClient${b.actor_name.capitalize()} {\nmut:\n'
	for name, typ in b.core_struct_attrs {
		str += '\t$name\t$typ\n'
	}
	str += '}\n'

	str += '\npub struct ${b.actor_name.capitalize()}Client {\n'
	str += '\t${b.actor_name}_address string\n}\n\n'
	str += 'pub fn new(${b.actor_name}_id string) !${b.actor_name.capitalize()}Client {\n'
	str += '\tsupervisor := supervisor_client.new("0")\n'
	str += '\t${b.actor_name}_address := supervisor.get_address("${b.actor_name}", ${b.actor_name}_id)!\n'
	str += '\treturn ${b.actor_name.capitalize()}Client{\n'
	str += '\t\tbaobab: baobab_client.new()\n\t}\n}\n\n'
	mut methods := b.actor_methods.clone() 
	methods << b.flow_methods.clone()
	for method in methods {
		str += 'pub fn (client ${b.actor_name.capitalize()}Client) ${method.name} ('
		for _, data in method.inputs {
			str += '${data.name} ${data.data_type}, '
		}
		str = str.trim_right(', ')
		str += ') !'
		if method.name == 'get' {
			str += 'IClient${b.actor_name.capitalize()} '
		} else {
			if method.outputs.len == 1 {
				str += '${method.outputs[0].data_type} '
			} else if method.outputs.len > 1 {
				str += '('
				for _, data in method.outputs {
					str += '${data.data_type}, '
				}
				str = str.trim_right(', ')
				str += ')'
			}
		}
		str +=  ' {\n'
		str +=  '\tj_args := params.Params{}\n'
		for _, data in method.inputs {
			if data.data_type.contains('.') {
				str += "\tj_args.kwarg_add('${data.name}', json.encode(${data.name}))\n"
			} else {
				str += "\tj_args.kwarg_add('${data.name}', ${data.name})\n"
			}
		}
		str += '\tjob := flows.baobab.job_new(\n'
		str += "\t\taction: 'hotel.${b.actor_name}.${method.name}'\n"
		str += '\t\targs: j_args\n'
		str += '\t)!\n'
		str += '\tresponse := client.baobab.job_schedule_wait(job, 100)!\n'
		str += '\tif response.state == .error {\n'
		str += "\t\treturn error('Job returned with an error')\n\t}\n"

		if method.name == 'get' {
			for flavor in b.instance_flavors {
				str += '\tif decoded := json.decode(models.$flavor, response) {\n'
				str += '\t\treturn decoded\n\t}\n'
			}
			str += '\treturn error("Failed to decode ${b.actor_name} type")'

		} else {
			str += '\treturn '
			for _, data in method.outputs {
				if data.data_type.contains('.') {
					str += "json.decode(${data.data_type}, response.result.get('${data.name}')!)!, "
				} else {
					str += "response.result.get('${data.name}')!, "
				}
			}
			str = str.trim_right(', ')
		}

		str += '\n}\n\n'
	}

	// str += 'pub fn (mut client Client) get (name string) !INew${b.actor_name.capitalize()} {\n'
	// str += '\tjson_${b.actor_name} := client.supervisor.get(name)!'
	


/*
pub interface IClientKitchen {}

pub fn (client KitchenClient) get (name string) !INewKitchen {
	j_args := params.Params{}
	j_args.kwarg_add('product_id', product_id)
	job := flows.baobab.job_new(
		action: 'hotel.kitchen.get_product'
		args: j_args
	)!
	response := client.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	if decoded_kitchen := json.decode(models.Kitchen, response) {
		return decoded_kitchen
	} else {
		if decoded_kitchen := json.decode(models.BrandKitchen, json_kitchen) {
			return decoded_kitchen
		}
	}
	return error("Failed to decode kitchen type")
}

*/


	b.client_text = str
}
