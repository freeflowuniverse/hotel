module flows

import freeflowuniverse.hotel.library.common
import freeflowuniverse.crystallib.params
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.flow_methods

import json

fn (flows GuestFlows) get_guest_code_from_handle (user_id string, channel_type string) !string {
	j_args := params.Params{}
	j_args.kwarg_add('user_id', user_id)
	j_args.kwarg_add('channel_type', channel_type)
	job := flows.baobab.job_new(
		action: 'hotel.guest.send_guest_code_from_handle'
		args: j_args
	)!
	response := flows.baobab.job_schedule_wait(job, 100)!
	if response.state == .error {
		return error("Failed to get guest code from $channel_type user_id: $user_id")
	}
	return response.result.get('guest_code')
}

fn (flows GuestFlows) validate_product_code (code string) !bool {
	return flow_methods.validate_product_code(code, flows.baobab)!
}
