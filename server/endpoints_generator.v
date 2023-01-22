module main

import freeflowuniverse.crystallib.params
import os

const (
	food_path = os.dir(@FILE) + '/foods.v'
	drinks_path = os.dir(@FILE) + '/drinks.v'
	products_path = os.dir(@FILE) + '/products.v'
	boats_path = os.dir(@FILE) + '/boats.v'
	rooms_path = os.dir(@FILE) + '/rooms.v'
	allergens_path = os.dir(@FILE) + '/allergens.v'
	customers_path = os.dir(@FILE) + '/customers.v'
	purchases_path = os.dir(@FILE) + '/purchases.v'
	server_path = os.dir(@FILE) + '/server.v'
)

fn main() {
	// ! DONT RUN, this will overwrite a number of new endpoints
	// reset_files(['foods', 'drinks', 'products', 'boats', 'rooms', 'allergens', 'customers', 'purchases'])!
	// mut endpoints := create_endpoints()
	// for endpoint in endpoints.endpoints {
	// 	function_text := parse_endpoint(endpoint)
	// 	file_dest_ := endpoint.endpoint.split('/')[1]
	// 	write_endpoint(function_text, file_dest_)
	// }
}

struct Endpoints {
pub mut:
	endpoints []Endpoint
}

struct Endpoint {
	endpoint        string
	request_method  string
	function        string
}

pub fn write_endpoint(function_text string, file_dest_ string) {
	file_destination := match file_dest_ {
		'foods' {food_path}
		'drinks' {drinks_path}
		'products' {products_path}
		'boats' {boats_path}
		'rooms' {rooms_path}
		'allergens' {allergens_path}
		'customers' {customers_path}
		'purchases' {purchases_path}
		else {server_path}
	}
	mut file := os.open_append(file_destination) or {panic("Failed to open $file_destination: $err")}
	file.writeln(function_text) or {panic("Failed to write line to function")}
	file.close()
}

pub fn reset_files (file_names []string) ! {
	imports := 'module main

import vweb
import os
import json
'
	for file_name in file_names {
		os.write_file('${os.dir(@FILE)}/${file_name}.v', imports) or {return error("Failed to write to file: $err")}
	}
}

pub fn parse_endpoint(endpoint Endpoint) string {
	title_function := '${endpoint.function}_api'
	mut endpoint_parts := endpoint.endpoint.split('/').filter(it!='')
	mut parameters := ''
	mut arguments := ''
	for part in endpoint_parts {
		if part[0].ascii_str() == ':' {
			parameters += '${part.all_after(":")} string,'
			arguments += '${part.all_after(":")},'
		}
	}
	function := endpoint.function
	response := match endpoint.request_method {
		'get' {'return app.json(instance)'} 
		'post' {'return app.text("Post Operation Sucessful")'}
		'delete' {'return app.text("Delete Operation Successful")'}
		else {'return app.text("Unrecognised request method")'} // TODO Should throw an error
	}

	mut function_call := ''
	if endpoint.request_method == 'post' {
		function_call = '
	params := json.decode(params.Params, app.req.data) or {
		app.set_status(400, "")
		return app.text("Failed to decode json, error: ${'$'}err")
	}
	app.h.${function}(params)'
	} else {
		function_call = 'instance := app.h.${function}($arguments)'
	}

	text := "
['${endpoint.endpoint}'; $endpoint.request_method]
pub fn (mut app App) $title_function ($parameters) vweb.Result {

$function_call or {
	app.set_status(500, '')
	return app.text('Function call failed: ${'$'}err')
}

$response 
}
"
	return text //TODO check if it is valid to do ${'$'}
}

pub fn create_endpoints () Endpoints {
	mut endpoints := Endpoints{}
	endpoints.endpoints << get_post_get_delete("customer").endpoints
	endpoints.endpoints << get_post_get_delete("boat").endpoints
	endpoints.endpoints << get_post_get_delete("room").endpoints
	endpoints.endpoints << get_post_get_delete("food").endpoints
	endpoints.endpoints << get_post_get_delete("drink").endpoints
	endpoints.endpoints << get_post_get_delete("allergen").endpoints
	endpoints.endpoints << get_post_get_delete("purchase").endpoints
	return endpoints
}

fn get_post_get_delete (model_name string) Endpoints {
	mut endpoints := Endpoints{}
	endpoints.endpoints << Endpoint{
		endpoint: "/api/${model_name}s"
		request_method: "get"
		function: "get_${model_name}s"
	}
	endpoints.endpoints << Endpoint{
		endpoint: "/api/${model_name}s"
		request_method: "post"
		function: "add_${model_name}"
	}
	endpoints.endpoints << Endpoint{
		endpoint: "/api/${model_name}s/:id"
		request_method: "get"
		function: "get_${model_name}"
	}
	endpoints.endpoints << Endpoint{
		endpoint: "/api/${model_name}s/:id"
		request_method: "delete"
		function: "delete_${model_name}"
	}
	return endpoints
}