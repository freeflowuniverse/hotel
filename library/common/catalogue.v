module common


// CATALOGUE REQUEST

struct ProductAvailability {
Product
	available_slots []Slot
	available bool = true
}

struct Slot {
	start time.Time
	duration time.Time
}

struct CategoryFilter {
	bools []BoolFilter
}

struct BoolFilter {
	name string
	desired bool
}

struct NumberFilter {
	name string
	start f64
	end f64
}

struct DateFilter {
	name string
	start time.Time
	end time.Time
}

pub struct CatalogueRequest {
	products []ProductAvailability
	number_filters []DiscreteFilter
	date_filters []ContinuousFilter
	category_filters []CategoryFilter
	additional_attributes []Attribute
	// TODO other filters
}

// ? Should we convert attribute names to numbers?
// needs to convert an order into params
pub fn catalogue_to_params (catalogue common.CatalogueRequest) params.Params {
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

pub fn params_to_order (o params.Params) common.Order {
	method := match o.get('method')! {
		'create' {Method.create}
		'modify' {Method.modify}
		'delete' {Method.delete}
		else {Method.create}
	}

	mut response := false
	if o.get('response')! == 'true' { response = true }

	mut order := common.Order {
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

pub fn simple_catalogue_request (product_codes []string) map[string]CatalogueRequest {
	mut requests := map[string]CatalogueRequest{}
	for code in product_codes {
		actor_char := code[0].ascii_str()
		if actor_char !in requests.keys {
			requests[actor_char] = CatalogueRequest{}
		}
		requests[actor_char].products << ProductAvailability{
			id: code[0..(code.len)]
		}
	}
	return requests
}