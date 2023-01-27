module accountant

import time
import employee
import library

struct Accounting {
mut:
	registers      []Register
	digital_funds  []library.Price
	transactions   []Transaction // only refers to in/out of hotel
}

struct Transaction {
mut:
	id string
	subject     string
	amount      library.Price
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

// TODO figure out the different ways a hotel can transfer money out
type TransactionDetails = CashDetails | BankTransferDetails | CryptoTransferDetails

struct Register {
mut:
	id              string
	name            string
	physical_funds  []library.Price
	cash_validity   bool
	last_cash_check time.Time
}
