module main

import vweb
import os
import json

['/api/rooms'; get]
pub fn (mut app App) get_rooms_api () vweb.Result {

instance := app.h.get_rooms()

return app.json(instance) 
}


['/api/rooms'; post]
pub fn (mut app App) add_room_api () vweb.Result {


	params := json.decode(params.Params, app.req.data) or {
		app.set_status(400, "")
		return app.text("Failed to decode json, error: $err")
	}
	app.h.add_room(params) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Post Operation Sucessful") 
}


['/api/rooms/:id'; get]
pub fn (mut app App) get_room_api (id string,) vweb.Result {

instance := app.h.get_room(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}


['/api/rooms/:id'; delete]
pub fn (mut app App) delete_room_api (id string,) vweb.Result {

instance := app.h.delete_room(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Delete Operation Successful") 
}

