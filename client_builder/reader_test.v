module client_builder

fn test_get_curly_contents () {
	mut res1, mut res2 :=  get_curly_contents('1}2')
	assert res1 == '1'
	assert res2 == '2'
	res1, res2 = get_curly_contents('1{2}3}4')
	assert res1 == '1{2}3'
	assert res2 == '4'
	res1, res2 = get_curly_contents('1}2{3}4')
	assert res1 == '1'
	assert res2 == '2{3}4'
}

// todo add flows to these tests
fn test_parse_match_map () {
	// Single apostrophe test
	mut input := {
		"\n\t'func1' ": "\n\t\t output1 := func1(input1, input2) \n"
		"\n\t'func2' ": "\n\t\t mut output2, output3 := func2(input1, input2) \n\t"
		"\n\telse ": "\n\t\telse_content\n\t"
	}
	mut method1 := Method{
		name: 'func1'
	}
	method1.add_output('output1', '')

	mut method2 := Method{
		name: 'func2'
	}
	method2.add_output('output2', '')
	method2.add_output('output3', '')
	mut output := Client{
		spv_methods: [method1, method2]
	}
	assert parse_match_map(mut input) == output
}

fn test_read_router_function () {
	input := "(s Supervisor) handle_job (mut job ActionJob) {
	random_handling(thing1, thing2)
	struct := something{
		entry1: 1
		entry2: 2
	}
	match actionname {
		'func1' {
			output1 := func1(input1, input2)
		} 
		'func2' {
			mut output2, output3 := func2(input1, input2)
		}
		else {
			else_content
		} 
	}
}"

	mut method1 := Method{
		name: 'func1'
	}
	method1.add_output('output1', '')

	mut method2 := Method{
		name: 'func2'
	}
	method2.add_output('output2', '')
	method2.add_output('output3', '')
	mut output := Client{
		spv_methods: [method1, method2]
	}
	assert read_router_function(input) == output

}
	
// todo test structs etc
fn test_read_spv_methods () {
	functions := [
		'fn (struct Struct) func1 (input1 string, input2 int) !string {
			random_handling(thing1, thing2)
			struct := something{
				entry1: 1
				entry2: 2
			}
		}',
		'fn (struct Struct) func2 (input3 []string, input4 map[string]string) !([]string, int) {
			random_handling(thing1, thing2)
			struct := something{
				entry1: 1
				entry2: 2
			}
		}'
	]

	mut b := new()

	mut method1 := Method{
		name: 'func1'
	}
	method1.add_output('output1', '')

	mut method2 := Method{
		name: 'func2'
	}
	method2.add_output('output2', '')
	method2.add_output('output3', '')

	b.client.spv_methods << [method1, method2]
	b.read_spv_methods(functions)
	
	mut method3 := Method{
		name: 'func1'
	}
	method3.add_input('input1', 'string')
	method3.add_input('input2', 'int')
	method3.add_output('output1', 'string')

	mut method4 := Method{
		name: 'func2'
	}
	method4.add_output('output2', '[]string')
	method4.add_output('output3', 'int')
	method4.add_input('input3', '[]string')
	method4.add_input('input4', 'map[string]string')
	mut output := Client{
		spv_methods: [method3, method4]
	}

	assert b.client == output
}