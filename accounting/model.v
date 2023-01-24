module accountant

import finance
import time
import employee

struct Accounting {
mut:
	employee_ids   []string //varies depending on current employee
	registers      []Register
	digital_funds  []finance.Amount
	transactions   []Transaction // only refers to in/out of hotel
}

struct Transaction {
mut:
	subject     string
	amount      finance.Amount
	description string
	time        time.Time
	employee_id string
}

// TODO differentiate between different types of ways to send money out; cash, cheque, bank transfer etc
struct ExternalTransaction {
Transaction
mut:
	cash bool
}

struct Register {
mut:
	id              string
	name            string
	physical_funds  []finance.Amount
	cash_validity   bool
	last_cash_check time.Time
}
