module actor_builder

import freeflowuniverse.crystallib.pathlib
import os

pub fn dummy_params() []Param {
	param1 := Param{
		name: 'product'
		data_type: 'product.Product'
		src_module: Module{
			name: 'freeflowuniverse.hotel.library.product'
		}
	}
	param2 := Param{
		name: 'product_id'
		data_type: 'string'
	}
	param3 := Param{
		name: 'quantity'
		data_type: 'int'
	}
	param4 := Param{
		name: 'guest'
		data_type: 'user_model.Guest'
		src_module: Module{
			name: 'freeflowuniverse.hotel.actors.user.user_model'
		}
	}

	return [param1, param2, param3, param4]
}

pub fn dummy_methods() []IMethod {
	mut get := IMethod(GetMethod{})
	mut get_attr := IMethod(GetAttributeMethod{})
	mut edit_attr := IMethod(EditAttributeMethod{})
	mut custom := IMethod(CustomMethod{})

	params := dummy_params()
	mut methods := [get, get_attr, edit_attr, custom]

	for mut m in methods {
		m.actor_name = 'dummy_actor'
		m.name = 'dummy_method'
		m.inputs = params[0..2]
		m.outputs = params[2..4]
		m.src_module = Module{
			name: 'freeflowuniverse.hotel.actors.user'
		}
	}

	return [custom, get, get_attr, edit_attr]
}

pub fn dummy_builder() Builder {
	builder := Builder{
		core_interface: Interface{
			flavors: ['guest', 'employee']
			attrs: dummy_params()[0..3]
		}
		dir_path: pathlib.get(os.dir(@FILE) + '/test_folder')
		actor_name: 'user'
		actor_methods: dummy_methods()
	}

	return builder
}

/*
router_actor
router_branch
run_actor
new_actor
new_client
ac_file
make_struct
str
str
indent
client
methods
make_function

TODO
client_edit_attr
methods_edit_attr
client_get_attr
methods_get_attr
client_get
methods_get
client_custom
methods_custom
*/

/*
router_actor
router_branch
run_actor
new_actor
new_client
ac_file
make_struct
istr
ostr
indent
client
methods
make_function

TODO
client_edit_attr
methods_edit_attr
client_get_attr
methods_get_attr
client_get
methods_get
client_custom
methods_custom
*/

fn write_string(text string) ! {
	os.write_file(os.dir(@FILE) + '/log.v', text)!
}

fn test_router_branch() ! {
	methods := dummy_methods()
	mut text := ''
	branch_str, mut imports := router_branch('user', methods[3])

	assert branch_str.contains("'dummy_method' {
	product := json.decode(product.Product, job.args.get('product')!)!
	product_id := job.args.get('product_id')!
	quantity, guest := actor.user.dummy_method(product, product_id)
	job.result.kwarg_add('quantity', quantity)
	job.result.kwarg_add('guest', json.encode(guest))
}")

	imports = imports.filter(it.name != '')
	assert imports == [Module{
		name: 'freeflowuniverse.hotel.library.product'
	}]
}

// TODO update with new run function
fn test_run_actor() ! {
	builder := dummy_builder()
	run_str, mut imports := builder.run_actor()
	assert run_str.contains('pub fn (mut actor UserActor) run ()  {
	for {}
}')
}

fn test_new_actor() ! {
	builder := dummy_builder()
	new_str, mut imports := builder.new_actor()

	assert new_str.contains("pub fn new (user_instance IUser, id string) ! {
	return UserActor {
		id: id
		user: user_instance
		baobab: baobab_client.new('0') or {return error('Failed to create baobab client with error: \\n\$err')}
	}
}")

	imports = imports.filter(it.name != '')
	assert imports == [
		Module{
			name: 'freeflowuniverse.baobab.client'
			alias: 'baobab_client'
		},
	]
}

fn test_new_client() ! {
	builder := dummy_builder()
	new_str, mut imports := builder.new_client()
	assert new_str.contains("pub fn new (user_id string) !UserClient {

	mut supervisor := supervisor_client.new() or {
		return error('Failed to create a new supervisor client with error: \\n\$err')
	}
	user_address := supervisor.get_address('user', user_id)!
	return UserClient{
		user_address: user_address
		baobab: baobab_client.new('0') or {
			return error('Failed to create new baobab client with error: \\n\$err')
		}
	}
}")

	imports = imports.filter(it.name != '')
	assert imports == [
		Module{
			name: 'freeflowuniverse.baobab.client'
			alias: 'baobab_client'
		},
		Module{
			name: 'freeflowuniverse.hotel.actors.supervisor.supervisor_client'
		},
	]
}

// TODO verify imports
fn test_make_struct() {
	params := dummy_params()
	struct_str, mut imports := make_struct('Dummy', params, true, false)
	assert struct_str.contains('pub struct Dummy {
pub mut:
	product	product.Product
	product_id	string
	quantity	int
	guest	user_model.Guest	
}')
	imports = imports.filter(it.name != '')
	assert imports == [Module{
		name: 'freeflowuniverse.hotel.library.product'
	}, Module{
		name: 'freeflowuniverse.hotel.actors.user.user_model'
	}]
}

fn test_istr() {
	params := dummy_params()
	input_str := params.istr()
	assert input_str.contains('product product.Product, product_id string, quantity int, guest user_model.Guest')
}

fn test_ostr() {
	params := dummy_params()
	bracket_str := params.ostr(true)
	plain_str := params.ostr(false)
	assert bracket_str.contains('(product.Product, string, int, user_model.Guest)')
	assert plain_str.contains('product.Product, string, int, user_model.Guest')

	// assert input_str.contains("product product.Product, product_id string, quantity int, guest user_model.Guest")
	// write_string(bracket_str + '\n\n\n' + plain_str)!
}

fn test_indent() {
	input := "for input in inputs {
	if input.data_type == 'string' {
		string_inputs << input
	}
}"
	assert indent(input, 1) == "	for input in inputs {
		if input.data_type == 'string' {
			string_inputs << input
		}
	}"
	assert indent(input, 2) == "		for input in inputs {
			if input.data_type == 'string' {
				string_inputs << input
			}
		}"
}

fn test_make_function() {
	params := dummy_params()

	f1 := FunctionParams{
		name: 'dummy'
		public: true
		receiver: params[3]
		inputs: [params[0]]
		outputs: params[1..3]
		body: indent('body', 1)
		type_: .classic
	}
	f2 := FunctionParams{
		name: 'dummy_2'
		public: false
		inputs: params[0..2]
		outputs: params[2..4]
		body: indent('body', 1)
		type_: .result
	}

	func1, mut imports1 := make_function(f1)
	assert func1.contains('pub fn (mut guest user_model.Guest) dummy (product product.Product) (string, int) {
	body
}')
	imports1 = imports1.filter(it.name != '')
	assert imports1 == [Module{
		name: 'freeflowuniverse.hotel.library.product'
	}, Module{
		name: 'freeflowuniverse.hotel.actors.user.user_model'
	}]

	func2, mut imports2 := make_function(f2)
	assert func2.contains('fn dummy_2 (product product.Product, product_id string) !(int, user_model.Guest) {
	body
}')
	imports2 = imports2.filter(it.name != '')
	assert imports2 == [Module{
		name: 'freeflowuniverse.hotel.library.product'
	}, Module{
		name: 'freeflowuniverse.hotel.actors.user.user_model'
	}]
}

fn test_custom_client() {
	custom := dummy_methods()[0]
	if custom is CustomMethod {
		m_str, mut imports := custom.client()
		imports = imports.filter(it.name != '')
		write_string('${imports}')!
		assert imports == [
			Module{
				name: 'freeflowuniverse.hotel.library.product'
			},
			Module{
				name: 'freeflowuniverse.hotel.actors.user.user_model'
			},
			Module{
				name: 'freeflowuniverse.hotel.library.product'
			},
			Module{
				name: 'freeflowuniverse.hotel.actors.user.user_model'
			},
		]
		assert m_str == "pub fn (mut dummy_actor_client Dummy_actorClient) dummy_method (product product.Product, product_id string) !(int, user_model.Guest) {
	mut j_args := params.Params{}
	j_args.kwarg_add('product', json.encode(product))
	j_args.kwarg_add('product_id', product_id)
	mut job := dummy_actor_client.baobab.job_new(
		action: 'hotel.dummy_actor.dummy_method'
		args: j_args
	)!
	response := dummy_actor_client.baobab.job_schedule_wait(mut job, 100)!
	if response.state == .error {
		return error('Job returned with an error')
	}
	return response.result.get('quantity')!, json.decode(user_model.Guest, response.result.get('guest')!)!
}"
	}
}

fn test_get_client() {}

fn test_get_attribute_client() {}

fn test_edit_attribute_client() {}

// struct FunctionParams {
// 	name string
// 	receiver Param
// 	inputs []Param
// 	outputs []Param
// 	public bool
// 	body string
// 	type_ Type
// }
