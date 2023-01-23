module main

import vweb
import os
import json

['/api/allergens'; get]
pub fn (mut app App) get_allergens_api () vweb.Result {

instance := app.h.get_allergens()

return app.json(instance) 
}


['/api/allergens'; post]
pub fn (mut app App) add_allergen_api () vweb.Result {


	params := json.decode(params.Params, app.req.data) or {
		app.set_status(400, "")
		return app.text("Failed to decode json, error: $err")
	}
	app.h.add_allergen(params) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Post Operation Sucessful") 
}


['/api/allergens/:id'; get]
pub fn (mut app App) get_allergen_api (id string,) vweb.Result {

instance := app.h.get_allergen(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}


['/api/allergens/:id'; delete]
pub fn (mut app App) delete_allergen_api (id string,) vweb.Result {

instance := app.h.delete_allergen(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Delete Operation Successful") 
}

['/api/allergens/stringified'; get]
pub fn (mut app App) get_allergens_api () vweb.Result {

instance := app.h.get_allergens_stringified()

return app.json(instance) 
}

['/api/allergens/stringified:id'; get]
pub fn (mut app App) get_allergen_api (id string,) vweb.Result {

instance := app.h.get_allergen_stringified(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}