module restaurant 

struct RestaurantActor {
	id string
	restaurant IRestaurant
	baobab Client
}

// main function that listens and never stops running
fn (actor UserActor) run () {
	// needs to perform actionrunner infinite for loop
}

// function that takes incoming jobs and executes on the response
fn (actor RestaurantActor) execute (mut job ActionJob) ! {
	// there are many actor_methods ie order
	// but always one flow: main_flow
	match actionname {
		'order' {
			param1 := job.params.get('param1')
			result := actor.user.actor_method(param)
			job.result.kwarg_add('result', result)
		}
		'main_flow' {
			user_id := job.params.get('user_id')
			result := actor.restaurant.main_flow(user_id, restaurant.id)
			job.result.kwarg_add('result', result)
		}
	}
}
