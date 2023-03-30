module product

import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.product
import freeflowuniverse.crystallib.params

import time
import json

// CATALOGUE REQUEST

pub struct ProductAvailability {
product.Product
pub mut:
	available_slots []Slot
	available bool = true
}

// todo look at this in more detail
pub struct Slot {
	start time.Time
	duration time.Time
}

// pub struct CategoryFilter {
// 	bools []BoolFilter
// }

// pub struct BoolFilter {
// 	name string
// 	desired bool
// }

// pub struct DiscreteFilter {
// 	name string
// 	start f64
// 	end f64
// }

// pub struct ContinuousFilter {
// 	name string
// 	start time.Time
// 	end time.Time
// }

pub struct CatalogueRequest {
pub mut:
	products []ProductAvailability
	// todo 
	// number_filters []DiscreteFilter
	// date_filters []ContinuousFilter
	// category_filters []CategoryFilter
	// additional_attributes []Attribute
}

fn get_product(product_id string, mut baobab client.Client) !ProductAvailability {
	actor_name := match_code_to_vendor(product_id[0].ascii_str())!
	catalogue_response := get_catalogue([product_id], actor_name, mut baobab)!
	return catalogue_response.products[0]
}

fn get_catalogue (product_ids []string, actor_name string, mut baobab client.Client) !CatalogueRequest {

	mut j_args := params.Params{}

	mut request := CatalogueRequest{}
	
	mut everything := false
	if product_ids.len == 0 {
		everything = true
	} else {
		for id in product_ids {
			request.products << ProductAvailability{
				id: id
			}
		}
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