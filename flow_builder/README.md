Currently flows have a lot of boiler plate, but they are effectively just a series of questions, so this can be code generated.

Flows can be viewed as trees with two types of nodes, branch and linear nodes, so we just need to define what the nodes are and the rest of the code should be boiler plate.

pub struct Node {
	name string
	flow_message string
	choice_action string
	access_condition string
    child_nodes []string
}

pub struct Flow {
    actor_name string
    actor_id string
    user_id string
}

pub struct KitchenFlow {
    Flow
}

When writing:
1. find the root node and create the root_node function

fn  root_node (user_id string, actor_id string) {
    // initialize KitchenFlow with actor_name, id and user_id
    // create a new ui client (if this is done at every step, maybe this should be passed along?)
    // Validation to check which sub-options a user should be presented with
    // Question posed to user with sub-options
    // match function connecting user_choice to next flow
}

fn (flow KitchenFlow) linear_node () {
    // perform some action
    // create a new ui client
    // Question posed to user (not about navigation, about data, so only one place to go from here)
    // send user on to next node
}

fn (flow KitchenFlow) branch_node () {
    // perform some action (should this be done here or at)
    // create a new ui client (if this is done at every step, maybe this should be passed along?)
    // Validation to check which sub-options a user should be presented with
    // Question posed to user with sub-options
    // match function connecting user_choice to next flow
}