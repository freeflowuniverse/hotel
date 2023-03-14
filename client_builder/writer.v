module client_builder

import os

pub fn (mut b Builder) write_file (file_dest_path string) ! {
	if os.exists(file_dest_path) {
		os.rm(file_dest_path)!
	}
	mut dest_file := os.create(file_dest_path)!
	defer {
		dest_file.close()
	}

	b.generate_client()
	// b.client_string := $tmpl('examples/client_template.md')
	dest_file.write_string(b.client_string)!
}

// todo this might be a bit too tough
pub fn (mut b Builder) generate_tests () {
	// this one is more difficult
	// todo create dummy tests for the guest supervisor
}

pub fn (mut b Builder) generate_client () {
	mut str := ''

	str += 'module ${b.client.name}_client\n\n'
	str += 'import json\n\n'
	str += 'import freeflowuniverse.crystallib.params\n'
	str += 'import freeflowuniverse.baobab.client as baobab_client\n'
	for imp in b.client.imports {
		str += '${imp}\n'
	}
	str += '\npub struct ${b.client.name.capitalize()}Client{}\n\n'
	str += 'pub fn new() ${b.client.name.capitalize()}Client {\n'
	str += '\treturn ${b.client.name.capitalize()}Client{\n'
	str += '\t\tbaobab: baobab_client.new()\n\t}\n}\n\n'
	for method in b.client.spv_methods {
		//pub fn (client GuestClient) add_guest (guest_person person.Person) !string {
		str += 'pub fn (client ${b.client.name.capitalize()}Client) ${method.name} ('
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
		str +=  '{\n'
		str +=  '\tj_args := params.Params{}\n'
		for _, data in method.inputs {
			if data.data_type.contains('.') {
				str += "\tj_args.kwarg_add('${data.name}', json.encode(${data.name}))\n"
			} else {
				str += "\tj_args.kwarg_add('${data.name}', ${data.name})\n"
			}
		}
		str += '\tjob := flows.baobab.job_new(\n'
		str += "\t\taction: 'hotel.${b.client.name}.${method.name}'\n"
		str += '\t\targs: j_args\n'
		str += '\t)!\n'
		str += '\tresponse := client.baobab.job_schedule_wait(job, 100)!\n'
		str += '\tif response.state == .error {\n'
		str += "\t\treturn error('Job returned with an error')\n\t}\n"
		str += '\treturn '
		for _, data in method.outputs {
			if data.data_type.contains('.') {
				str += "json.decode(${data.data_type} ,response.result.get('${data.name}')!)!, "
			} else {
				str += "response.result.get('${data.name}')!, "
			}
		}
		str += '\n}\n\n'
	}
	b.client_string = str
}
