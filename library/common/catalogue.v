module common

import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.product

import json

// CATALOGUE REQUEST

struct ProductAvailability {
product.Product
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

fn get_product (product_id string, actor_name string, baobab client.Client) !ProductAvailability {

	request := CatalogueRequest{
		products: [ProductAvailability{
			id: product_id
		}]
	}
	
	j_args := params.Params{}
	j_args.kwarg_add('catalogue_request', json.encode(request))
	job := baobab.job_new(
		action: 'hotel.${actor_name}.get_catalogue'
		args: j_args
	)!

	response := baobab.job_schedule_wait(job, 100)!

	if response.state == .error {
		return error
	}
	return response.result.get('catalogue').products[0]
}


// ! pub fn simple_catalogue_request (product_codes []string) map[string]CatalogueRequest {
// 	mut requests := map[string]CatalogueRequest{}
// 	for code in product_codes {
// 		actor_char := code[0].ascii_str()
// 		if actor_char !in requests.keys {
// 			requests[actor_char] = CatalogueRequest{}
// 		}
// 		requests[actor_char].products << ProductAvailability{
// 			id: code[0..(code.len)]
// 		}
// 	}
// 	return requests
// }