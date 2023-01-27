module accounting

/*
Send Methods:
- 
*/

/*
Send Methods:
- 
*/

fn new () Accounting {

}

// ? can add funds and deduct funds be made into a single equation
// Add funds to person
// adds funds to a specific guest and adds same to accountant physical funds
// only add funds to physical funds if employee updates their own state
// Called by:
// ${interface}.deduct_funds_from_person(employee_id string, amount library.Price)
// Calls:
// person.deduct_digital_funds(employee_id string, amount library.Price) - in guest and employee
fn (mut accounting Accounting) add_funds_to_person(recipient_id string, amount library.Price) !Transaction {

	return Transaction{}
}

// ? Why did this return a transaction again?
// Deduct funds from person
// deducts funds from a specific guest
// Called by:
// ${interface}.deduct_funds_from_person(employee_id string, amount library.Price)
// Calls:
// person.deduct_digital_funds(library.Price) - in guest and employee
fn (mut accounting Accounting) deduct_funds_from_person(recipient_id string, amount library.Price) !Transaction {
	return Transaction{}
}

// external_payment_from_hotel
// Give cash out of the system to an external supplier/contractor
// TO USER / INTERNAL (if we create a wallet actor)
// Called by:
// storage.send_external_payment_request
// Calls:
// $interface.external_payment_from_accounting
fn (mut accounting Accounting) external_payment_from_accounting (transaction Transaction) !Transaction {

}

fn (mut accounting Accounting) report_external_payment_status (employee_id string, complete bool, note string) ! {

	if complete == true {
		transaction := Transaction{
			
		}

		accounting.transactions << transaction
	}

		
}

// Check cash register
// prompts someone to check the cash registry
// TO USER
fn (mut accounting Accounting) check_cash_register(register_id string) ! {
}

// Update register status
// gets an input from the physical accountant, update the status of the register
// FROM USER
fn (mut accounting Accounting) update_cash_register_status(register_id string) ! {
}

// Get physical funds
// Getter function to return the physical funds contained by the actor
// INTERNAL
fn (accounting Accounting) get_physical_funds() {
}

// Get transaction history
// Getter function to return transactions
// INTERNAL
fn (accounting Accounting) get_transactions (actor_id string) {

}

// Collect digital funds
// collect digital funds from restaurant, bar, dock, etc and adds it to digital_funds
// INTERNAL / FROM USER (would be better to do an internal timer)
fn (accounting Accounting) add_funds_from_internal (sender string, amount library.Price) ! {

}

