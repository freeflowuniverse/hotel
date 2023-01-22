module hoteldb

import freeflowuniverse.crystallib.params
import freeflowuniverse.backoffice.finance

[heap]
struct CustomerHandles {
	telegram_username  string
}

[heap]
pub struct Customer {
	CustomerHandles
pub mut:
	id         		  string
	firstname  		  string
	lastname   		  string
	funds             map[string]finance.Amount // string is currency_name
	funds_log         []string
}

pub fn get_s () {

}

pub fn add_ () {
	
}

pub fn get_ () {
	
}

pub fn delete_ () {
	
}

pub fn (db HotelDB) get_customers () ![]&Customer {
	mut customers := []&Customer{}
	for customer in db.customers {
		customers << &customer
	}
	return customers
}

pub fn (db HotelDB) get_customer (id string) !&Customer {
	for customer in db.customers {
		if customer.id == id {
			return &customer
		}
	}
	return error("Could not find customer $id in hotel database.")
}

pub fn (db HotelDB) add_fund (customer_id string, amount_string string) ! {
	mut customer := db.get_customer(customer_id) or {return error("Failed to get customer: $err")}

	amount := db.currencies.amount_get(amount_string) or {return error("Failed to get amount from '$amount_string': $err")}

	if customer.funds[amount.currency.name] == finance.Amount{} {
		customer.funds[amount.currency.name] = amount
	} else {
		customer.funds[amount.currency.name] = finance.add_amounts([customer.funds[amount.currency.name], amount]) or {return error("Failed to add amounts: $err")}
	}
	customer.add_log(amount)
}

pub fn (db HotelDB) remove_fund (customer_id string, amount_string string, hard string) ! {
	if hard == 'true' {
		db.remove_fund_hard(customer_id, amount_string) or {return error("Failed to do hard remove of funds '$amount_string': $err")}
	} else {
		mut customer := db.get_customer(customer_id) or {return error("Failed to get customer: $err")}

		mut amount := db.currencies.amount_get(amount_string) or {return error("Failed to get amount from '$amount_string': $err")}

		if customer.funds[amount.currency.name] == finance.Amount{} {
			return error("The customer does not have any funds with that balance")
		} else if customer.funds[amount.currency.name].val < amount.val {
			return error("The customer does not have a large enough balance in $amount.currency.name")
		} else {
			amount.val = -amount.val
			customer.funds[amount.currency.name] = finance.add_amounts([customer.funds[amount.currency.name], amount]) or {return error("Failed to add amounts: $err")}
		}
		customer.deduct_log(amount)
	}
}

fn (db HotelDB) remove_fund_hard (customer_id string, amount_string string) ! {
	mut customer := db.get_customer(customer_id) or {return error("Failed to get customer: $err")}

	mut amount := db.currencies.amount_get(amount_string) or {return error("Failed to get amount from '$amount_string': $err")}

	outer: for currency_name, customer_amount in customer.funds {
		amount.change_currency(db.currencies, currency_name) or {return error("Failed to change change currency: $err")}
		if amount.val > customer_amount.val {
			customer.funds[currency_name].val = 0
			amount.val -= customer_amount.val
			customer.deduct_log(customer_amount)
		} else {
			customer.funds[currency_name].val = customer_amount.val - amount.val
			customer.deduct_log(amount)
			break outer
		}
	}
}

pub fn (mut customer Customer) add_log (amount finance.Amount) {
	log_message := "Customer ID: $customer.id - $amount.val $amount.currency.name added to customer account."
	customer.funds_log << log_message
}

pub fn (mut customer Customer) deduct_log (amount finance.Amount) {
	log_message := "Customer ID: $customer.id - $amount.val $amount.currency.name deducted from customer account."
	customer.funds_log << log_message
}

fn (customer Customer) get_total_usd (db HotelDB) !finance.Amount {
	mut amount := db.currencies.amount_get("0USD") or {return error("This should never happen: $err")}
	for currency_name, customer_amount in customer.funds {
		amount.change_currency(db.currencies, currency_name)  or {return error("Failed to change currency to $currency_name: $err")}
		amount = finance.add_amounts([amount, customer_amount]) or {return error("Failed to add amounts: $err")}
	}
	return amount
}

fn (mut db HotelDB) add_customer (mut o params.Params) ! {

	db.generate_customer_id()

	customer := Customer{
		id : db.generate_customer_id()
		firstname : o.get('firstname')!
		lastname : o.get('lastname')!
		telegram_username: o.get('telegram_username')!
	}

	db.customers << customer
}

fn (db HotelDB) generate_customer_id () string {
	mut greatest_id := 0
	for customer in db.customers {
		if customer.id.int() > greatest_id {
			greatest_id = customer.id.int()
		}
	}
	return (greatest_id + 1).str()
}

pub fn (customer Customer) name() string {
	return "$customer.firstname $customer.lastname"
}

fn record_customer () {
	// TODO 
}
