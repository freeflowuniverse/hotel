module flows

import freeflowuniverse.hotel.library.product.flows

struct KitchenFlows {
	baobab client.Client
	actor_name string
}

pub fn new_flows() KitchenFlows {
	return KitchenFlows{
		baobab: client.new()
		actor_name: 'kitchen'
	}
}

// todo check that this is valid, is this properly implementing the IVendorFlows interface