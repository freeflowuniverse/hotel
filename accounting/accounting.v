module accounting

fn new () Accounting {

}

// Employee login
// Allows an employee to login to the treasury
fn (mut accounting Accounting) employee_login (employee_id string) {

}

// ? can add funds and deduct funds be made into a single equation
// Add funds to person
// adds funds to a specific guest and adds same to accountant physical funds
// only add funds to physical funds if employee updates their own state
fn (mut accounting Accounting) add_funds_to_person(recipient_id string, amount finance.Amount) !Transaction {

	return Transaction{}
}

// ? Why did this return a transaction again?
// Deduct funds from person
// deducts funds from a specific guest
fn (mut accounting Accounting) deduct_funds_from_person(transaction Transaction) !Transaction {
	return Transaction{}
}

// Transfer funds
// Give cash out of the system to an external supplier/contractor
fn (mut accounting Accounting) transfer_funds_from_hotel(transaction Transaction) !Transaction {

}

// Check cash register
// prompts someone to check the cash registry
fn (mut accounting Accounting) check_cash_register(register_id string) ! {
}

// Update register status
// gets an input from the physical accountant, update the status of the register
fn (mut accounting Accounting) update_cash_register_status(register_id string) ! {
}

// Get physical funds
// Getter function to return the physical funds contained by the actor
fn (accounting Accounting) register_physical_funds_receipt() {
}

// Get transaction history
// gets a history of all transactions that have taken place
fn (accounting Accounting) get_transaction_history (actor_id string) {

}

// Collect digital funds
// collect digital funds from restaurant, bar, dock, etc and adds it to digital_funds
fn (accounting Accounting) add_funds_from_internal (sender string, amount finance.Amount) ! {

}

