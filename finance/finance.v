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


pub fn (currencies Currencies) amount_get (amount_ string) !Amount {
	mut amount := amount_
	numbers := ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']
	for i in ['_', ',',' '] {
		amount = amount.replace(i, '')
	}

	mut negative := false
	if amount[0].ascii_str() == '-' {
		negative = true
		amount = amount.all_after('-')
	}

	// checks if amount or code given first
	mut num_first := false
	item := amount[0..1]
	if item in numbers {
		num_first = true
	}

	// split up string into two parts, code and amount
	mut code := ''
	mut num := ''
	mut split_string := amount.split('')
	if num_first {
		mut count := 0
		for index in split_string {
			if index !in numbers {
				num = amount[0..count]
				code = amount[count..amount.len]
				break
			}
			count += 1
		}
	} else {
		mut count := 0
		for index in split_string {
			if index in numbers {
				code = amount[0..count]
				num = amount[count..amount.len]
				break
			}
			count += 1
		}
	}
	// remove spaces from code and capitalise
	if code == '' {
		return error("No currency code given")
	}

	mut code_nice := match code {
		'$', '' {'USD'}
		'£' {'GBP'}
		'€' {'EUR'}
		else {code.to_upper()}
	}
	
	// currencies := get_currencies()!

	if currencies.currencies[code_nice] == Currency{} {
		return error("Could not find the currency")
	}

	currency := (currencies.currencies[code_nice])


	mut amount2 := Amount{
		val: f64(num.int())
		currency: currency //?How to handle an error here
	}

	if negative {
		amount2.val = -amount2.val
	}

	return amount2
}

pub fn add_amounts (amounts []Amount) !Amount {
	target_currency := amounts[0].currency
	mut total_val := f64(0)
	for amount in amounts {
		// if amount.currency != target_currency {
		// 	return error("Input amounts are of different currencies")
		// }
		total_val += amount.val
	}
	return Amount{
		currency: target_currency
		val: total_val
	}
}

pub fn (mut amount Amount) change_currency (currencies Currencies, currency_name string) ! {
	currency := currencies.get(currency_name) or {return error("Failed to get currency: $currency_name")}
	usd_ := amount.usd()
	amount.currency = currency
	amount.val = usd_ / currency.usdval // TODO check that this is valid 
}

struct ResponseBody {
	motd    string
	success string
	base    string
	date    string
	rates   map[string]f32
}

// // gets the latest currency exchange rates from an API
// // ARGS:
// // - an array of fiat codes e.g ['EUR', 'AED']
// // - an array of crypto codes e.g ['TERRA']
// pub fn get_rates(fiat_array []string, crypto_array []string) !(map[string]f32, map[string]f32) {
// 	mut fiat_codes := fiat_array.str()
// 	for i in ["'", '[', ']', ' '] {
// 		fiat_codes = fiat_codes.replace(i, '')
// 	}

// 	mut crypto_codes := crypto_array.str()
// 	for i in ["'", '[', ']', ' '] {
// 		crypto_codes = crypto_codes.replace(i, '')
// 	}
// 	mut crypto_decoded := ResponseBody{}
// 	if crypto_array != [] {
// 		response := http.get('https://api.exchangerate.host/latest?base=USD&symbols=$crypto_codes&source=crypto') or {return error("Failed to get crypto http response: $err")}
// 		crypto_decoded = json.decode(ResponseBody, response.body) or {return error("Failed to decode crypto json: $err")}
// 	}
// 	mut fiat_decoded := ResponseBody{}
// 	if fiat_array != [] {
// 		response := http.get('https://api.exchangerate.host/latest?base=USD&symbols=$fiat_codes') or {return error("Failed to get fiat http response: $err")}
// 		fiat_decoded = json.decode(ResponseBody, response.body) or {return error("Failed to decode fiat json: $err")}
// 	}

// 	return fiat_decoded.rates, crypto_decoded.rates
// }

pub fn (currencies Currencies) get (name_string string) !Currency {
	for key, currency in currencies.currencies {
		if key == name_string.to_upper() {
			return currency
		}
	}
	return error("Failed to find $name_string in currencies")
}

// Gets the latest currency exchange rates from a hardcoded list
// ARGS:s
pub fn get_currencies() !Currencies { // ! fiat_codes_ []string
	// mut fiat_codes := fiat_codes_.clone()
	// for code in ['EUR', 'USD', 'GBP', 'EGP', 'AED'] {
	// 	if code !in fiat_codes {
	// 		fiat_codes << code
	// 	}
	// }
	// crypto_codes := []string{} //['TFT', 'USDC']
	// fiat_rates, crypto_rates := get_rates(fiat_codes, []) or {return error("Failed to get rates for: $fiat_codes, $crypto_codes")}

	// mut currencies := Currencies{}
	// for name, exchange in fiat_rates {
	// 	currencies.currencies[name] = Currency{
	// 		name: name, 
	// 		usdval: 1/exchange
	// 	}
	// }
	mut usd := Currency{
		name: 'USD'
		usdval: 1
	}

	mut eur := Currency{
		name: 'EUR'
		usdval: 0.984
	}

	mut gbp := Currency{
		name: 'GBP'
		usdval: 1.1199
	}

	mut tft := Currency{
		name: 'TFT'
		usdval: 0.0292
	}

	mut egp := Currency{
		name: 'EGP'
		usdval: 0.0509
	}

	mut aed := Currency{
		name: 'AED'
		usdval: 0.2723
	}

	mut usdc := Currency{
		name: 'USDC'
		usdval: 1.0000
	}

	mut tzs := Currency{
		name: 'TZS'
		usdval: 0.000428
	}

	mut currencies := Currencies{
		currencies: {
			'EUR':   eur
			'GBP':   gbp
			'USD':   usd
			'TFT':   tft
			'AED':   aed
			'USDC':  usdc
			'EGP':   egp
			'TZS': tzs
		}
	}

	return currencies
}

pub fn (a Amount) usd() f64 {
	// calculate usd value towards f64
	usd_val := a.val * a.currency.usdval
	return f64(usd_val)
}