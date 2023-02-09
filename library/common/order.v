module common

// ORDER

enum Method {
	create
	modify
	delete
}

// an exchange of goods or services with specific magnitude defined
pub struct Order {
	id string
	for_id string
	orderer_id string // ? is this necessary? isnt it covered in the actionjob
    start time.Time // desired time for order to arrive or for booking to start
	product_amounts []ProductAmount
	note string
	method Method
	additional_attributes []Attribute
	completed bool
	target_actor string
}

// todo completed needs to be changed to status

/*
enum OrderStatus {
	open
	started
	finished
	cancelled
}

*/

// need to define a serializer for each order type

pub struct Attribute {
	key string
	value string
	value_type string //bool, int, f64
}


fn (order Order) stringify() string {
	mut ordstr := 'Order ID: $order.id\nTime: $order.start\n'
	if order.note != '' {
		ordstr += 'Note: $order.note\n'
	}
	if order.additional_attributes.len != 0 {
		ordstr += 'Additional Attributes:\n\n'
		for attr in order.additional_attributes {
			ordstr += '${attr.key.capitalize()}: $attr.value\n'
		}
	}
	ordstr += '\nProducts:\n\n'
	for pa in order.product_amounts {
		ordstr += '$pa.quantity x pa.product.name\n'
	}
	return ordstr
	
}