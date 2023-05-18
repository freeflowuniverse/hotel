module actor_builder

fn (mut b Builder) create_actor() ! {
	mut actor_file := File{
		mod: '${b.actor_name}'
		path: b.dir_path.extend_file('actor.v')!
	}
	attributes := [Param{
		name: 'id'
		data_type: 'string'
	}, Param{
		name: '${b.actor_name}'
		data_type: 'I${b.actor_name.capitalize()}'
	}, Param{
		name: 'baobab'
		data_type: 'baobab_client.Client'
		src_module: Module{
			name: 'freeflowuniverse.baobab.client'
			alias: 'baobab_client'
		}
	}]

	actor_file.add(make_object('${b.actor_name.capitalize()}Actor', attributes, true,
		false))
	actor_file.add(b.new_actor())
	actor_file.add(b.run_actor())
	actor_file.add(b.router_actor()!)
	actor_file.write_file()!
}

fn (b Builder) new_actor() Chunk {
	body := "return ${b.actor_name.capitalize()}Actor {
	id: id
	${b.actor_name}: ${b.actor_name}_instance
	baobab: baobab_client.new('0') or {return error('Failed to create baobab client with error: \\n\$err')}
}"

	func, _ := make_function(
		name: 'new'
		inputs: [
			Param{
				name: '${b.actor_name}_instance'
				data_type: 'I${b.actor_name.capitalize()}'
			},
			Param{
				name: 'id'
				data_type: 'string'
			},
		]
		public: true
		body: indent(body, 1)
		type_: .result
	)

	imports := [
		Module{
			name: 'freeflowuniverse.baobab.client'
			alias: 'baobab_client'
		},
	]
	return Chunk{func, imports}
}

fn (b Builder) router_actor() !Chunk {
	mut imports := []Module{}
	mut branches := []string{}
	// router_branch (actor_name string, name string, inputs []Params, outputs []Params)
	for m in b.actor_methods {
		if m.name == 'delete' {
			branches << "'delete' {\n\tpanic('This actor has been deleted!')\n}"
		} else {
			chunk := router_branch(b.actor_name, m)
			branches << chunk.content
			imports.add_many(chunk.imports)
		}
	}
	

	body := "actionname := job.action.all_after_last('.')
match actionname {
${indent(branches.join_lines(),
		1)}
	else { return error(\"Could not identify the method name: '\$actionname' !\") }
}"

	mut router_str, router_imports := make_function(
		name: 'execute'
		receiver: Param{
			name: 'actor'
			data_type: '${b.actor_name.capitalize()}Actor'
		} // TODO check mut receiver
		inputs: [
			Param{
				name: 'job'
				data_type: 'baobab_jobs.ActionJob'
				src_module: Module{
					name: 'freeflowuniverse.baobab.jobs'
					alias: 'baobab_jobs'
				}
			},
		]
		public: true
		body: indent(body, 1)
		type_: .result
	)

	return Chunk{router_str, router_imports}
}

fn router_branch(actor_name string, method Method) Chunk {
	mut imports := []Module{}
	mut input_stmts := []string{}
	mut output_stmts := []string{}
	for input in method.inputs {
		mut parsed := "job.args.get('${input.name}')!"
		if input.data_type.contains('.') {
			parsed = 'json.decode(${input.data_type}, ${parsed})!'
		}
		parsed = '${input.name} := ${parsed}'
		imports.add_many([input.src_module])
		input_stmts << parsed
	}
	for output in method.outputs {
		mut stmt := output.name
		if output.data_type.contains('.') {
			stmt = 'json.encode(${stmt})'
		}
		stmt = "job.result.kwarg_add('${output.name}', ${stmt})"
		output_stmts << stmt
	}
	mut outputs := ''
	if method.outputs.len != 0 {
		outputs = "${method.outputs.map(it.name).join(', ')} := "
	}
	mut branch_string := "'${method.name}' {
	${input_stmts.join('\n\t')}
	${outputs}actor.${actor_name}.${method.name}(${method.inputs.map(it.name).join(', ')})
	${output_stmts.join('\n\t')}
}"
	return Chunk{branch_string, imports}
}

fn (b Builder) run_actor() Chunk {
	func, imports := make_function(
		name: 'run'
		receiver: Param{
			name: 'actor'
			data_type: '${b.actor_name.capitalize()}Actor'
		}
		public: true
		body: indent('for {}', 1)
	)

	return Chunk{func, imports}
}
