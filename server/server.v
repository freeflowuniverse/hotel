module main

import freeflowuniverse.hotel.hotel

import vweb
import os
import json

const (
	memdb_add_path = os.dir(@FILE) + '/../data/data_add'
	memdb_source_path = os.dir(@FILE) + '/../data/db.json'
)

struct App {
	vweb.Context
pub mut:
	config  map[string]string	
	h   hotel.Hotel
}

struct CustomResponse {
	status  int
	message string
}

fn (c CustomResponse) to_json() string {
	return json.encode(c)
}

pub fn check_headers(mut app App) ! {
	// Check if incoming request containes 'SECRET'
	// HTTPS/TLS should be used with this Authorization method. otherwise,
	// basic authentication should not be used to protect sensitive or valuable information.
	headers_keys := app.Context.req.header.keys()
	mut secret := ''
	if headers_keys.contains('Authorization') {
		secret = app.Context.req.header.get_custom(headers_keys[headers_keys.index('Authorization')])!
	} else {
		app.set_status(401, 'Unauthorized')
		err := CustomResponse{401, 'No authorization header found'}
		app.json(err)
		return
	}
	
	hotel_secret := get_env_token('HOTEL_SECRET') or {panic("Failed to get hotel secret: $err")}

	if secret != hotel_secret || secret == '' {
		app.set_status(403, 'Forbidden')
		err := CustomResponse{403, 'Invalid secret sent in header'}
		app.json(err)
	}
}

pub fn get_env_token(token_name string) !string {
	env_secrets := os.read_lines("${os.dir(@FILE)}/../.env")!
	// println(env_secrets)
	// println("")
	// token_phrase := env_secrets[0].split('"')[1]
	// println(token_phrase)
	// println("")
	for env_secret in env_secrets {
		if env_secret.split('"')[0].trim_string_right("=") == token_name {
			return env_secret.split('"')[1]
		}
	}
	return error("Failed to find $token_name in .env")
}

pub fn (mut app App) before_request() {
	check_headers(mut app) or { panic(err) }
}

fn main () {
	vweb.run(new_app(), 8080)
}

fn new_app() &App {
	mut config := map[string]string{}

	bot_token := get_env_token('BOT_TOKEN') or {panic("Failed to get bot token: $err")}
	mut h := hotel.new('Jungle Paradise', bot_token, memdb_source_path) or {panic("Failed to create new hotel: $err")}

	h.add_md_data(memdb_add_path) or {panic("Failed to add data from md files: $err")}

	mut app := &App{
		config: config
		h: h
	}

	app.mount_static_folder_at(os.resource_abs_path('.'), '/')
	println("SERVER DB PATH: $app.h.db_path")

    return app
}

['/api/db'; get]
pub fn (mut app App) db() vweb.Result {
	println("FINAL PATH: $app.h.db_path")
	db := hotel.get_db(app.h.db_path.path) or {
        app.set_status(500, '')
        return app.text('$err')
	}

	return app.json(db)
}

//TODO endpoint to uptake md files // ? Would this be called through the endpoint or locally on the server?
