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

pub struct Amount {
pub mut:
	currency Currency
	val      f64
}
