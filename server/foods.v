module main

import vweb
import os
import json

['/api/foods'; get]
pub fn (mut app App) get_foods_api () vweb.Result {

instance := app.h.get_foods()

return app.json(instance) 
}


['/api/foods'; post]
pub fn (mut app App) add_food_api () vweb.Result {


	params := json.decode(params.Params, app.req.data) or {
		app.set_status(400, "")
		return app.text("Failed to decode json, error: $err")
	}
	app.h.add_food(params) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Post Operation Sucessful") 
}


['/api/foods/:id'; get]
pub fn (mut app App) get_food_api (id string,) vweb.Result {

instance := app.h.get_food(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}


['/api/foods/:id'; delete]
pub fn (mut app App) delete_food_api (id string,) vweb.Result {

instance := app.h.delete_food(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Delete Operation Successful") 
}

