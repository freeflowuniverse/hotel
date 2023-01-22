module main

import vweb
import os
import json

['/api/customers'; get]
pub fn (mut app App) get_customers_api () vweb.Result {

instance := app.h.get_customers()

return app.json(instance) 
}


['/api/customers'; post]
pub fn (mut app App) add_customer_api () vweb.Result {


	params := json.decode(params.Params, app.req.data) or {
		app.set_status(400, "")
		return app.text("Failed to decode json, error: $err")
	}
	app.h.add_customer(params) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Post Operation Sucessful") 
}


['/api/customers/:id'; get]
pub fn (mut app App) get_customer_api (id string,) vweb.Result {

instance := app.h.get_customer(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.json(instance) 
}


['/api/customers/:id'; delete]
pub fn (mut app App) delete_customer_api (id string,) vweb.Result {

instance := app.h.delete_customer(id,) or {
	app.set_status(500, '')
	return app.text('Function call failed: $err')
}

return app.text("Delete Operation Successful") 
}

