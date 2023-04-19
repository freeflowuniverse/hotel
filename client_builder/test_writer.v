module client_builder

import os

// ! This is not done yet, I think it is mostly copy pasted code.

pub fn (mut b Builder) write_tests (file_dest_path string) ! {
	$if debug { println("\tPerforming test file structure preparation ...") }
	dir := os.dir(file_dest_path)
	if os.exists(dir) == false {
		return error("This should be called after the client has been written")
	}
	mut dest_file := os.create(file_dest_path) or {return error("Failed to create file: $err")}
	defer {
		dest_file.close()
	}
	$if debug { println("\tGenerating client string ...") }
	b.generate_tests_string()
	$if debug { println("\tWriting client string ...\n") }
	dest_file.write_string(b.tests_string)  or {return error("Failed to write client string to file: $err")}

}


pub fn (mut b Builder) generate_tests_string () {
	mut str := ''

	str += 'module ${b.actor_name}_client\n\n'
	str += 'import json\n\n'
	str += 'import freeflowuniverse.crystallib.params\n'
	str += 'import freeflowuniverse.baobab.client as baobab_client\n'
	str += 'import freeflowuniverse.hotel.actors.supervisor.supervisor_client\n'
	str += 'import freeflowuniverse.hotel.actors.${b.actor_name}\n'
	// todo import the main actor module
	for imp in b.imports {
		str += 'import ${imp}\n'
	}
	str += '\npub struct ${b.actor_name.capitalize()}Client {\n'
	str += '\t${b.actor_name}_address string\n}\n\n'
	str += 'pub fn new(${b.actor_name}_id string) !${b.actor_name.capitalize()}Client {\n'
	str += '\tsupervisor := supervisor_client.new("0")\n'
	str += '\t${b.actor_name}_address := supervisor.get_address("${b.actor_name}", ${b.actor_name}_id)!\n'
	str += '\treturn ${b.actor_name.capitalize()}Client{\n'
	str += '\t\tbaobab: baobab_client.new()\n\t}\n}\n\n'
	mut methods := b.actor_methods.clone() 
	methods << b.flow_methods.clone()
	for method in  methods{
		//pub fn (client GuestClient) add_guest (guest_person person.Person) !string {
		str += 'pub fn (client ${b.actor_name.capitalize()}Client) ${method.name} ('
		for _, data in method.inputs {
			str += '${data.name} ${data.data_type}, '
		}
		str += ') !'
		if method.outputs.len == 1 {
			str += '${method.outputs[0].data_type} '
		} else if method.outputs.len > 1 {
			str += '('
			for _, data in method.outputs {
				str += '${data.data_type}, '
			}
			str += ')'
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
		str += '\treturn '
		for _, data in method.outputs {
			if data.data_type.contains('.') {
				str += "json.decode(${data.data_type}, response.result.get('${data.name}')!)!, "
			} else {
				str += "response.result.get('${data.name}')!, "
			}
		}
		str = str.trim_right(', ')
		str += '\n}\n\n'
	}
	b.client_string = str
}