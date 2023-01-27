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
	guest_id string // ? is this necessary? isnt it covered in the actionjob
	product_code string // actor_character product_id concatenated
    start time.Time
    quantity int
	note string
	method Method
	response bool = false
	additional_attributes []Attribute
}

// need to define a serializer for each order type

pub struct Attribute {
	key string
	value string
	value_type string //bool, int, f64
}

// needs to convert an order into params
pub fn order_to_params (order Order) params.Params {
	mut order_params := params.new_params()
	order_params.kwarg_add('id', order.id)
	order_params.kwarg_add('guest_id', order.guest_id)
	order_params.kwarg_add('product_code', order.product_code)
	order_params.kwarg_add('start', order.start.unix_time.str())
	order_params.kwarg_add('quantity', order.quantity.str())
	order_params.kwarg_add('note', order.note)

	order_params.kwarg_add('method', '$order.method')
	order_params.kwarg_add('response', order.response.str())
	order_params.kwarg_add('additional_attributes', json.encode(order.additional_attributes))
	return order_params
}

pub fn params_to_order (o params.Params) Order {
	method := match o.get('method')! {
		'create' {Method.create}
		'modify' {Method.modify}
		'delete' {Method.delete}
		else {Method.create}
	}

	mut response := false
	if o.get('response')! == 'true' { response = true }

	mut order := Order {
		id: o.get('id')!
		guest_id: o.get('guest_id')!
		product_code: o.get('product_code')! // actor_character product_id concatenated
		start: unix(o.get('start')!.f64())
		quantity: o.get('quantity')!.str()
		note: o.get('note')!
		method: method
		response: response
		additional_attributes: json.decode([]Attribute, o.get('additional_attributes'))
	}

	return order
}