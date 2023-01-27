module guest

struct LaundryRequestHandlers {}

fn (lrh LaundryRequestHandlers) expose_laundry_order_confirmation (params Params) ! {
	params.get('order_confirmation')
	json.decode
	
	// confirmation = convert Params into Order
}

fn (lrh LaundryRequestHandlers) expose_laundry_prices (laundry_services []Product)