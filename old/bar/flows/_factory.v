module flows

import freeflowuniverse.hotel.library.product.flows

struct BarFlows {
	baobab client.Client
	actor_name string
}

pub fn new_flows() BarFlows {
	return BarFlows{
		baobab: client.new()
		actor_name: 'bar'
	}
}