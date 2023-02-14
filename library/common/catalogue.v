module common

import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.product
import freeflowuniverse.crystallib.params

import time
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

struct DiscreteFilter {
	name string
	start f64
	end f64
}

struct ContinuousFilter {
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

fn get_product(product_id string, actor_name string, mut baobab client.Client) !ProductAvailability {
	catalogue_response := get_catalogue([product_id], actor_name, mut baobab)!
	return catalogue_response.products[0]
}

fn get_catalogue (product_ids []string, actor_name string, mut baobab client.Client) !CatalogueRequest {

	mut j_args := params.Params{}

	mut request := CatalogueRequest{}
	
	for id in product_ids {
		request.products << ProductAvailability{
			id: product_id
		}
	}
	
	mut everything := false
	if product_ids.len == 0 {
		everything = true
	}

	j_args.kwarg_add('everything', '$everything')
	j_args.kwarg_add('catalogue_request', json.encode(request))
	mut job := baobab.job_new(
		action: 'hotel.${actor_name}.send_catalogue'
		args: j_args
	)!

	response := baobab.job_schedule_wait(mut job, 100)!

	if response.state == .error {
		return error("Failed to get product")
	}

	catalogue := response.result.get('catalogue')!
	return json.decode(CatalogueRequest, catalogue)!
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