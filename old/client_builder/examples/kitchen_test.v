module kitchen_client

import freeflowuniverse.hotel.actors.kitchen
import freeflowuniverse.hotel.actors.kitchen.kitchen_client
import freeflowuniverse.baobab

fn testsuite_begin() {
	// todo clear redis and all that
}

fn init () !kitchen_client.KitchenClient {
	// todo create a new processor
	// todo create a new actionrunner
	// todo create a new kitchen actor
	// todo spawn the above
	// todo create a new kitchen client
	// todo return the client
}

// ? is this necessary?
fn deinit () {
	// todo end all the functions started in init
}

// todo for function in kitchen_client
pub fn test_get_product () ! {
	mut kc := init()
	// INSERT REAL/TEST VALUES BELOW --------
	// ie product := product.Product{}

	
	// INSERT ACTOR INITS BELOW -------------
	// ie kc.create_product(product)!


	// --------------------------------------
	
	assert kc.get_product()! == 
	assert kc.get_product()! == 
	// ie assert kc.get_product(product.id)! == product
	deinit()
}
