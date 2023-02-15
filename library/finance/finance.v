module finance

import time
import json
import freeflowuniverse.crystallib.params
import freeflowuniverse.baobab.client

// TODO move out of hotel

pub struct Currencies {
pub mut:
	currencies map[string]Currency
}

[heap]
pub struct Currency {
pub mut:
	name   string = 'USD'
	usdval f64 = 1
}

pub struct Price {
pub mut:
	currency Currency
	val      f64
}

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
	total_amount Price
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

pub fn (mut price Price) multiply (number int) Price {
	mut new_price := price
	new_price.val = price.val*number
	return new_price
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

pub fn (mut p1 Price) deduct (p2 Price) ! {
	if p1.currency.name != p2.currency.name {
		return error("Prices are of different currencies")
	}
	p1.val = p1.val - p2.val
}

pub fn (mut p1 Price) add (p2 Price) ! {
	if p1.currency.name != p2.currency.name {
		return error("Prices are of different currencies")
	}
	p1.val = p1.val + p2.val
}