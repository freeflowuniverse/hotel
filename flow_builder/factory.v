module flow_builder

pub struct Nodes {
	nodes []Node
}

pub struct Node {
	name string
	action []string // lines of code
	@match Match
}

pub struct Match {
	condition string
	branches map[string]Branch
}

pub struct Branch {
	next_node string
	action []string
}

/*
Node
- action
- match dependent on some input either from an actor or from the user or pre-existing data
- branches (contain next node + optional action + params)
*/


fn new_nodes () Nodes {
	return Nodes{}
}

fn (mut ns Nodes) add (n Node) !Node {
	// if ns.nodes.filter(it.name == n.parent_node_name).len != 1 && n.name.to_lower().contains('root') == false {
	// 	return error("Could not find parent node, please ensure the parent_node value is the name of another node.")
	// } else 
	if ns.nodes.any(it.name==n.name) {
		return error("A node with the name '${n.name}' already exists, please give this node a different name.")
	}
	ns.nodes << n
	return n
}

// EXAMPLE



mut ns := new_nodes()

mut order := ns.add(
	name: 'order_node'
	action: 'mut order := common.Order{}'
	condition: 'flow.user.user_type'
)

root.add_branch(
	state: '.employee'
	next_node: 'init_guest_order_node'
)

root.add_branch(
	state: '.employee'
	next_node: 'init_employee_order_node'
)

mut init_employee := ns.add(
	name: 'init_employee_order_node'
	action: ['\tguest_id := flow.ui.ask_string("What is the guests id code")', '\supervisor := supervisor_client.new("0")']
	condition: 'user, user_type := supervisor.find_user(guest_id, "id")'
)

init_employee.add_branch(
	state: 'true'
	action: ['order.for_id = user.id']
	next_node: 'choose_new_product_node'
)

init_employee.add_branch(
	state: 'false'
	action: ['flow.ui.send_message("Guest ID not recognised")']
	next_node: 'init_employee_order_node'
)


mut init_guest := ns.add(
	name: 'init_guest_order_node'
	action: 'order.for_id = flow.user.id'
)

init_guest.add_branch(
	state: 'true'
	next_node: 'choose_new_product_node'
)
