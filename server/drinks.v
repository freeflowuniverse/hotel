module main

import vweb
import os
import json

['/api/drinks'; get]
pub fn (mut app App) get_drinks_api () vweb.Result {

instance := app.h.get_drinks()

return app.json(instance) 
}


['/api/drinks'; post]
pub fn (mut app App) add_drink_api () vweb.Result {


	params := json.decode(params.Params, app.req.data) or {
		app.set_status(400, "")
		return app.text("Failed to decode json, error: $err")
	}
	app.h.add_drink(params) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Post Operation Sucessful") 
}


['/api/drinks/:id'; get]
pub fn (mut app App) get_drink_api (id string,) vweb.Result {

instance := app.h.get_drink(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}


['/api/drinks/:id'; delete]
pub fn (mut app App) delete_drink_api (id string,) vweb.Result {

instance := app.h.delete_drink(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Delete Operation Successful") 
}

['/api/drinks/stringified'; get]
pub fn (mut app App) get_drinks_api () vweb.Result {

instance := app.h.get_drinks_stringified()

return app.json(instance) 
}

['/api/drinks/stringified:id'; get]
pub fn (mut app App) get_drink_api (id string,) vweb.Result {

instance := app.h.get_drink_stringified(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}