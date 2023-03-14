module user 

struct UserActor {
	id string
	user IUser
	baobab Client
}

fn (actor UserActor) new (user IUser) UserActor {
	return UserActor{}
}

// main function that listens and never stops running
fn (actor UserActor) run () {
	// needs to perform actionrunner infinite for loop
}

// function that takes incoming jobs and executes on the response
fn (actor UserActor) execute (mut job ActionJob) ! {
	match actionname {
		'order' {
			param1 := job.params.get('param1')
			result := actor.user.actor_method(param)
			job.result.kwarg_add('result', result)
		}
		'main_flow' {
			user_id := job.params.get('user_id')
			result := actor.user.main_flow(user_id)
			job.result.kwarg_add('result', result)
		}
	}
}

