module flows 

import freeflowuniverse.crystallib.params
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.flow_methods

fn (flows EmployeeFlows) get_guest_code (firstname string, lastname string, email string) !string {

	j_args := params.Params{}

	j_args.kwarg_add('firstname', firstname)
	j_args.kwarg_add('lastname', lastname)
	j_args.kwarg_add('email', email)

	job := flows.baobab.job_new(
		action: 'hotel.guest.send_guest_code_from_details' //todo
		args: j_args
	)!

	response := flows.baobab.schedule_job_wait(job, 0)!
	if response.result.exists('guest_code'){
		return response.result.get('guest_code')
	} else {
		return error("Guest does not exist")
	}
}

fn (flows EmployeeFlows) validate_product_code (code string) !bool {
	return flow_methods.validate_product_code(code, flows.baobab)!
}


