module main

import vweb
import os
import json

['/api/boats'; get]
pub fn (mut app App) get_boats_api () vweb.Result {

instance := app.h.get_boats() 

return app.json(instance) 
}


['/api/boats'; post]
pub fn (mut app App) add_boat_api () vweb.Result {


	params := json.decode(params.Params, app.req.data) or {
		app.set_status(400, "")
		return app.text("Failed to decode json, error: $err")
	}
	app.h.add_boat(params) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Post Operation Sucessful") 
}


['/api/boats/:id'; get]
pub fn (mut app App) get_boat_api (id string,) vweb.Result {

instance := app.h.get_boat(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}


['/api/boats/:id'; delete]
pub fn (mut app App) delete_boat_api (id string,) vweb.Result {

instance := app.h.delete_boat(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Delete Operation Successful") 
}

