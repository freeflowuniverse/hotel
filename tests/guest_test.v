module tests

import freeflowuniverse.hotel.guest
import freeflowuniverse.baobab.jobs {ActionJob}
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.product
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.baobab.actor
import freeflowuniverse.baobab.actionrunner
import freeflowuniverse.baobab.client
import freeflowuniverse.baobab.processor
import freeflowuniverse.crystallib.params

import time
import json

fn testsuite_begin() ! {

	// create baobab, actionrunner and processor
	mut b := client.new()!
	mut guestactor := guest.new()!
	mut ar := actionrunner.new(b, [&actor.IActor(guestactor)])
	mut processor := processor.Processor{}

	// concurrently run actionrunner, processor, and external client
	spawn (&ar).run()
	spawn (&processor).run()
}

fn test_guest_actor() {
	mut b := client.new() or { panic(err) }
	mut guest_person := person.Person{}

	d_person := dummy_person()
	guest_code := ag_test(mut b, d_person) or {panic("ag_test: $err")}
	assert guest_code.len == 4
	guest_person = sgp_test(mut b, guest_code) or {panic("sgp_test: $err")}
	assert guest_person == d_person

	assert vgc_test(mut b, guest_code) or {panic("vgc_test: $err")} == true
	assert vgc_test(mut b, guest_code.to_lower()) or {panic("vgc_test: $err")} == true

	assert sgcfd_test(mut b, 'John', 'Smith', 'john@gmail.com') or {panic(err)} == guest_code

	d_order := dummy_order(guest_code)
	assert lo_test(mut b, d_order) or {panic("lo_test: $err")} == true
	expected_balance := finance.Price{
		val: -20
		currency: finance.Currency{
			name: 'USD'
			usdval: 1
		}
	}
	gp := sgp_test(mut b, guest_code) or {panic("sgp_test: $err")}
	assert gp.digital_funds == expected_balance
	active_orders := sgao_test(mut b, guest_code) or {panic("sgao_test: $err")}
	assert active_orders.len > 0
	assert active_orders[0].id == '12'

	assert sgcfh_test(mut b, 'johnsmith', 'telegram')! == guest_code
}

fn ag_test (mut b client.Client, guest_person person.Person) !string {
	mut job := create_job([['guest_person', json.encode(guest_person)]], 'guest.add_guest')!
	response := b.job_schedule_wait(mut job, 0)!
	return response.result.get('guest_code')!
}

fn lo_test (mut b client.Client, order common.Order) !bool {
	mut job := create_job([['order', json.encode(order)]], 'guest.log_order')!
	response := b.job_schedule_wait(mut job, 0)!
	if response.state == .done {
		return true
	} else {
		return false
	}
}

fn sgp_test (mut b client.Client, guest_code string) !person.Person {
	mut job := create_job([['guest_code', guest_code]], 'guest.send_guest_person')!
	response := b.job_schedule_wait(mut job, 0)!
	return json.decode(person.Person, response.result.get('guest_person')!)!
}

fn sgcfd_test (mut b client.Client, firstname string, lastname string, email string) !string {
	mut job := create_job([['firstname', firstname],['lastname', lastname],['email',email]], 'guest.send_guest_code_from_details')!
	response := b.job_schedule_wait(mut job, 0)!
	return response.result.get('guest_code')!
}

fn vgc_test (mut b client.Client, guest_code string) !bool {
	mut job := create_job([['guest_code', guest_code]], 'guest.validate_guest_code') or {return error("Failed to create job: $err")}
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	return response.result.get('guest_code')!.bool()
}

fn sgao_test (mut b client.Client, guest_code string) ![]common.Order {
	mut job := create_job([['guest_code', guest_code]], 'guest.send_guest_active_orders') or {return error("Failed to create job: $err")}
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	return json.decode([]common.Order, response.result.get('active_orders')!)!
}

fn sgcfh_test (mut b client.Client, user_id string, channel_type string) !string {
	mut job := create_job([['user_id', user_id],['channel_type', channel_type]], 'guest.send_guest_code_from_handle') or {return error("Failed to create job: $err")}
	response := b.job_schedule_wait(mut job, 0) or {return error("Failed to schedule wait job: $err")}
	return response.result.get('guest_code')!
}

// TODO 
// 'log_order_cancellation' {
// 	actor.log_order_cancellation(mut job)!
// }
// 'send_guest_code_from_handle' {
// 	actor.send_guest_code_from_handle(mut job)!
// }

// fn loc_test () ! {
	
// }

fn create_job (pairs [][]string, actor_function string) !ActionJob {
	mut j_args := params.Params{}
	for pair in pairs {
		j_args.kwarg_add(pair[0], pair[1])
	}
	return jobs.new(
		action: 'hotel.$actor_function'
		args: j_args
	)!
}

fn dummy_person () person.Person {
	return person.Person{
		id: '23'
		firstname: 'John'
		lastname: 'Smith'
		email: 'john@gmail.com'
		telegram_username: 'johnsmith'
		phone_number: '0779876543'
	}
}

fn dummy_order (guest_code string) common.Order {
	order := common.Order{
		id: '12'
		for_id: guest_code
		orderer_id: guest_code
		start: time.now()
		product_amounts: [product.ProductAmount{
			quantity: '2'
			product: product.Product{
				id: 'R12'
				name: 'Chicken Curry'
				description: 'A delicious chicken curry served with vegetables'
				state: .ok
				price: finance.Price{
					val: 10
					currency: finance.Currency{
						name: 'USD'
						usdval: 1
					}
				}
				unit: .units
				variable_price: true
			}
		}]
		note: 'note'
		additional_attributes: [common.Attribute{
			key: 'room_service'
			value: 'true'
			value_type: 'bool'
		}]
		order_status: .open
		target_actor: 'restaurant'
	}
	return order
}