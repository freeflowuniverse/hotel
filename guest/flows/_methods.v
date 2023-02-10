module flows

import freeflowuniverse.hotel.library.common
import freeflowuniverse.crystallib.params

fn (flows GuestFlows) get_guest_code_from_telegram (user_id string) !string {
	j_args := params.Params{}
	j_args.kwarg_add('telegram_username', user_id)
	job := flows.baobab.job_new(
		action: 'hotel.guest.get_guest_code_from_telegram'
		args: j_args
	)!
	response := flows.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error("Failed to get guest from telegram")
	}
	return response.result.get('guest_code')
}

// ! duplicated from employee
fn (flows EmployeeFlows) validate_product_code(code string) !bool {
	actor_name := match code[0].ascii_str() {
		'K' {'kitchen'}
		'B' {'bar'}
		else {''}
	}

	if actor_name == '' { return false }

	response := common.get_product(code[1..(code.len)], actor_name)
	
	if response.state == .error { return false }
	return true
}