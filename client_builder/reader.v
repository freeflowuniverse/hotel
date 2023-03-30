module client_builder

import v.ast
import v.pref
import v.parser
import os

// todo imports
// todo if a sum type is returned, then the client should recognise this and decode and set the output with the correct

const (
	fpref = &pref.Preferences{
		is_fmt: true
	}
)

pub fn (mut b Builder) read_actor_dir(dir_path string) ! {
	b.actor_name = dir_path.split('/').last()
	$if debug { println("\tReading file actor.v ...") }
	b.read_actor('${dir_path}/actor.v')!
	$if debug { println("\tReading file ${b.actor_name}.v ...") }
	b.read_methods('${dir_path}/${b.actor_name}.v')!
	if os.exists('${dir_path}/flows.v') {
		$if debug { println("\tReading file flows.v ...") }
		b.read_flows('${dir_path}/flows.v')!
	}
	b.fix_import_types()
	$if debug { println("\tSuccessfully read ${b.actor_name} directory!\n") }
}

fn (mut b Builder) read_actor(file_path string) ! {
	actor_file, _ := read_file(file_path)
	$if debug { println("\t\tFiltering file statements...") }
	execute_fn := actor_file.stmts.filter(it is ast.FnDecl).map(it as ast.FnDecl).filter(it.name == 'execute')[0]

	match_exprs := execute_fn.stmts.filter(it is ast.ExprStmt).map(it as ast.ExprStmt).filter(it.expr is ast.MatchExpr).map(it.expr).map(it as ast.MatchExpr)

	match_expr := match_exprs.filter((it.cond as ast.Ident).name == 'actionname')[0]

	$if debug { println("\t\tEvaluating router match function branches...") }
	for branch in match_expr.branches {
		$if debug { println("\t\t\tEvaluating next branch...") }
		mut flow_bool := false
		if branch.is_else {
			break
		}
		mut method := Method{
			name: branch.exprs.map(it as ast.StringLiteral)[0].val
		}
		mut output_order := []string{}
		for stmt in branch.stmts {
			$if debug { println("\t\t\t\tEvaluating branch statement:  ${stmt.str().split('\n')[0]}") }
			match stmt {
				ast.AssignStmt {
					mut right := stmt.right[0] as ast.CallExpr
					if stmt.right[0].str().contains('params.get(') {
						if right.name == 'decode' {
							right = right.args[1].expr as ast.CallExpr
						}
						$if debug { println("\t\t\t\t\tInput: ${right.args[0].str()}") }
						method.add_input(right.args[0].str().trim('"').trim("'"), '')
					} else if stmt.right.str().contains("${b.actor_name}.${method.name}") {
						for result in stmt.left {
							output_order << result.str()
							$if debug { println("\t\t\t\t\tOutput: ${result.str()}") }
						}
					}
				}
				// todo will need to modify this part of the reader to accomodate for sum type casting
				// this should be covered already

				// todo will need to do imports for variable types

				ast.ExprStmt {
					if stmt.expr.str().contains('.result.kwarg_add(') {
						call_expr := stmt.expr as ast.CallExpr
						var_name := call_expr.args[0].str().trim('"').trim("'")
						pos := output_order.index(var_name)
						if pos == -1 {
							return error('Invalid naming conventions for results and kwargs!')
						}
						method.add_output(var_name, '', pos)
					} else if stmt.expr.str().starts_with('go ') {
						flow_bool = true
					}
				}
				else {}
			}
		}
		if flow_bool {
			b.flow_methods << method
		} else {
			b.actor_methods << method
		}
	}
}

fn (mut b Builder) read_methods(file_path string) ! {
	method_file, table := read_file(file_path)
	functions := method_file.stmts.filter(it is ast.FnDecl).map(it as ast.FnDecl)

	for function in functions {
		if b.actor_methods.any(it.name == function.name) {
			mut method := &b.actor_methods.filter(it.name == function.name)[0]
			for param in function.params {
				for _, mut input in method.inputs {
					if input.name == param.name {
						input.data_type = table.type_str(param.typ)
					}
				}
			}
			mut count := 0
			mut new_import := ''
			for return_type in table.type_str(function.return_type).trim('()').split(',') {
				// todo sum type handling
				method.outputs[count].data_type, new_import = parse_type(return_type.trim_space(), method_file.imports)
				if new_import != '' && b.imports.any(it==new_import) == false {
					b.imports << new_import
				}
				count += 1
			}
		}
	}
}

fn (mut b Builder) read_flows(file_path string) ! {
	flows_file, table := read_file(file_path)

	functions := flows_file.stmts.filter(it is ast.FnDecl).map(it as ast.FnDecl)


	for function in functions {
		function_name := function.name.all_after_last('.')
		if b.flow_methods.any(it.name == function_name) {
			mut method := &b.flow_methods.filter(it.name == function_name)[0]

			for param in function.params {
		
				for _, mut input in method.inputs {
					mut new_import := ''
					if input.name == param.name {
						input.data_type, new_import = parse_type(table.type_str(param.typ), flows_file.imports)
						if new_import != '' && b.imports.any(it==new_import) == false {
							b.imports << new_import
						}
					}
				}
			}
		}
	}
}

// todo should do a test here which makes sure that everything is valid

fn parse_type (type_name string, imports []ast.Import) (string, string) {
	// println("*********************************")
	// println(type_name)
	mut required_import := ''
	if type_name.contains('.') {
		// println("CHECK VALUE --- ${type_name.all_before_last('.').all_after_last('.')}")
		mut prefix := ''
		if type_name.contains(']') {
			prefix = "${type_name.all_before_last(']')}]"
		}
		chunks := type_name.all_after_last(']').split('.')
		short_type := "$prefix${chunks#[-2..].join('.')}"
		// This gets the appropriate import
		for import_ in imports {
			// println("${type_name.all_before_last('.').all_after_last('.')} -- ${import_.alias}")
			if type_name.all_before_last('.').all_after_last('.') == import_.alias {
				required_import = import_.mod
				// println("RECOGNISED --- $short_type --- $required_import")
				// println("*********************************")
				return short_type, required_import
			}
		}
		// todo check if sum type and get sum type
	}
	// println("NOT RECOGNISED --- $type_name")
	// println("*********************************")
	return type_name, ''
}

fn (mut b Builder) fix_import_types () {
	for mut method in b.actor_methods {
		for _, mut input in method.inputs {
			b.validate_data_type(mut input)
		}
		for _, mut output in method.outputs {
			b.validate_data_type(mut output)
		}
	}
}

fn (mut b Builder) validate_data_type (mut input Data) {
	type_name := input.data_type
	mut prefix := ''
	if type_name.contains(']') {
		prefix = "${type_name.all_before_last(']')}]"
	}
	if type_name.count('.') > 1 {
		chunks := type_name.all_after_last(']').split('.')
		input.data_type = "$prefix${chunks#[-2..].join('.')}"
		new_import := chunks[0..(chunks.len-1)].join('.')
		if b.imports.any(it==new_import) == false {
			b.imports << new_import
		}
	}
}
/*
pub struct Data {
pub mut:
	name        string
	data_type   string
	sum_type    string
	import_stmt string
}
*/

fn read_file(file_path string) (&ast.File, &ast.Table) {
	table := ast.new_table()
	file_ast := parser.parse_file(file_path, table, .parse_comments, client_builder.fpref)
	return file_ast, table
}
