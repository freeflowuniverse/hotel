module accountant

import finance
import time
import employee

struct Accounting {
	employee_id    string //varies depending on current employee
	registers      []Register
	digital_funds  []finance.Amount
	transactions   []Transaction // only refers to in/out of hotel
}

pub struct Transaction {
	subject     string
	sender      string // actor_id.instance_id (instance_id is optional)
	recipient   string // actor_id.instance_id
	amount      finance.Amount
	description string
	time        time.Time
}

struct Register {
	id              string
	name            string
	physical_funds  []finance.Amount
	cash_validity   bool
	last_cash_check time.Time
}
