module vendor

import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuinverse.hotel.library.common
import freeflowuniverse.crystallib.params

import json

pub interface VendorMixin {
	open_judgements []OpenJudgement
	orders []common.Order
	employee_ids []string
}

// todo move orders into VendorMixin (maybe change to an interface)

pub struct OpenJudgement {
	order_id string
	flow_guids []string
	source_guid string
}

pub fn (vendor VendorMixin) announce_order (mut job ActionJob) ! {
	order := json.decode(common.Order, job.args.get('order'))

	mut j_args := params.Params{}
	j_args.kwarg_add('order', json.encode(order))
	j_args.kwarg_add('channel_type', telegram)
			
	for user_id in employee_telegrams {
		j_args.kwarg_add('user_id', user_id)
		n_job := actor.baobab.job_new(
			args: j_args
		)!
		actor.baobab.schedule_job(n_job, 0)!
	}
}

// returns job guid
pub fn (vendor VendorMixin) announce_cancellation_request (mut job ActionJob) ! {

	mut j_args := params.Params{}
	j_args.kwarg_add('order', job.args.get('order'))
	j_args.kwarg_add('channel_type', 'telegram')
		
	mut job_guids := []string{}

	for user_id in employee_telegrams {
		j_args.kwarg_add('user_id', user_id)
		n_job := actor.baobab.job_new(
			action: 'hotel.flowsactor.judge_cancellation'
			args: j_args
		)!
		actor.baobab.job_schedule(n_job)!
		job_guids << n_job.guid
	}

	vendor.open_judgements << OpenJudgement{
		order_id: json.decode(common.Order, job.args.get('order')!)!.id
		flow_guids: job_guids
		source_guid: job.guid
	}
}

// returns true for cancelled
pub fn (vendor VendorMixin) confirm_order_cancelled (mut job ActionJob, open_judgement OpenJudgement) ! {
	order_id := job.args.get('order_id')!
	order := vendor.orders.filter(it.id==order_id)

	mut j1_args := params.Params{}
	j1_args.kwarg_add('order', json.encode(order))
	job1 := actor.baobab.job_new(
		action: 'hotel.guest.log_order_cancellation'
		args: j1_args
	)!
	actor.baobab.job_schedule(job1)!

	mut j2_args := params.Params{}
	j2_args.kwarg_add('order', json.encode(order))
	j2_args.kwarg_add('vendor_name', vendor.actor_name)
	job2 := actor.baobab.job_new(
		action: 'hotel.flowsactor'
		args: j2_args
	)!
	job2.guid = open_judgement.source_guid
	job2.status = .done
	actor.baobab.job_schedule(job2)!
}

pub fn (vendor VendorMixin) close_order (mut job ActionJob) ! {
	order_id := job.args.get('order_id')!
	order := vendor.orders.filter(it.id==order_id).order_status = .closed
	job.state = .done
	actor.baobab.schedule(job)!
}
