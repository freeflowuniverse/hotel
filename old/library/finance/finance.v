module finance

import time
import json
import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.money
import freeflowuniverse.baobab.client

// TODO BELOW

pub struct BankTransferDetails {
mut: 
	bank_name string
	sort_code string
	account_number string
}

pub enum TransactionMedium {
	complimentary
	cash
	card
	coupon
	bank_transfer
}

// purely financial transaction from a sender to receiver with full detail
pub struct Transaction {
mut:
	id string
	sender string // TODO define more precisely what this represents
	receiver string // TODO define more precisely what this represents
	total_amount money.Money
	medium TransactionMedium
	bank_transfer_details BankTransferDetails
	note string
	transaction_status TransactionStatus
	time_of time.Time
	target_actor string
}

pub enum TransactionStatus {
	open
	closed
	cancelled
}

pub fn send_transaction (transaction Transaction, mut baobab client.Client) !bool {
	mut j_args := params.Params{}
	j_args.kwarg_add('transaction', json.encode(transaction))
	mut job := baobab.job_new(
		action: 'hotel.${transaction.target_actor}.receive_transaction'
		args: j_args
	)!
	response := baobab.job_schedule_wait(mut job, 100)!
	if response.state == .done {
		return true
	}
	return false
}
