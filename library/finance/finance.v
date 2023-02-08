module finance

// TODO move out of hotel

pub struct Currencies {
pub mut:
	currencies map[string]Currency
}

[heap]
pub struct Currency {
pub mut:
	name   string
	usdval f64
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
	completed bool
}

pub fn multiply (price Price, number int) Price {
	new_price := price
	new_price.val = price.val*number
	return new_price
}