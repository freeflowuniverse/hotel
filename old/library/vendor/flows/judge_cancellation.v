module flows

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common

pub fn (flows IVendorFlows) judge_cancellation (job ActionJob) {
	user_id := job.args.get('user_id')!
	channel_type := 'telegram' // todo how to do this?
	ui := ui.new(channel_type, user_id)

	order := json.decode(common.Order, job.args.get('order'))

	cancel_bool := ui.ask_yesno(
		question: "Is it still possible to cancel this order?:"
		description: order.stringify()
	)

	employee_person := flow_methods.get_employee_person_from_handle(user_id, channel_type, flows.baobab) or {
		ui.send_exit_message("Failed to get employee identity from $channel_type username. Please try again later.")
		return
	}

	if cancel_bool {
		job.state = .done
		job.result.kwarg_add('canceller_id', employee_person.id)
	} else {
		job.state = .error
	}
	flows.baobab.schedule_job(job)!
}