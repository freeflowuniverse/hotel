module user

import user_client
import ui_client
import ActionJob

struct User {
	id string
	name string
}

//actor_method
fn (mut user User) actor_method (param string) !string {

}
