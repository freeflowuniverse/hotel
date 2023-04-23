import freeflowuniverse.hotel.flow_builder

fn main () {
	mut ns := flow_builder.new_nodes()
	ns.add(
		name: 'Kitchen Root'
		flow_message: 'Welcome to the Jungle Paradise Kitchen! What would you like to do?'
	)
	ns.add(
		name: 'Order'
		parent_node: 'Kitchen Root'
		flow_message: 'Welcome to the Jungle Paradise Kitchen! What would you like to do?'
		choice_action: ''
		access_condition: ''
	)
}

