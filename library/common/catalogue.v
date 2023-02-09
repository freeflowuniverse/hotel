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