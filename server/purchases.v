module main

import vweb
import os
import json

['/api/purchases'; get]
pub fn (mut app App) get_purchases_api () vweb.Result {

instance := app.h.get_purchases() or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}


['/api/purchases'; post]
pub fn (mut app App) add_purchase_api () vweb.Result {


	params := json.decode(params.Params, app.req.data) or {
		app.set_status(400, "")
		return app.text("Failed to decode json, error: $err")
	}
	app.h.add_purchase(params) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Post Operation Sucessful") 
}


['/api/purchases/:id'; get]
pub fn (mut app App) get_purchase_api (id string,) vweb.Result {

instance := app.h.get_purchase(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}


['/api/purchases/:id'; delete]
pub fn (mut app App) delete_purchase_api (id string,) vweb.Result {

instance := app.h.delete_purchase(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Delete Operation Successful") 
}

