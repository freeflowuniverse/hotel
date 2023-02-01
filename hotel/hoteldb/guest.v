module hoteldb

import freeflowuniverse.hotel.finance
import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.pathlib

import rand
import os
import time

// todo check error where after registration a guest is deleted from guests.md

[heap]
pub struct Guest {
pub mut:
	code              string
	firstname  		  string
	lastname   		  string
	email             string
	orders            []Order
	payments          []Payment
	wallet            finance.Amount
	telegram_username string
	hotel_resident    bool
}

// pub fn (mut db HotelDB) get_bill (guest_code string) string {}

pub fn (mut db HotelDB) get_guest_code (guest_email string) !Guest {
	for mut guest in db.guests {
		if guest_email == guest.email {
			return guest
		}
	}
	return error("Guest email could not be found")
}

// adds a guest from tbot
pub fn (mut db HotelDB) add_guest (mut guest Guest) !string {

	if guest.email != '' {
		for old_guest in db.guests {
			if guest.email == old_guest.email {
				return "!$old_guest.code"
			}
		}
	}	

	guest.code = db.generate_guest_code()
	guest.wallet = db.currencies.amount_get('0USD')!
	guest.create_guest_folder()!

	db.guests << &guest
	return guest.code
}

// utility function to create new folder when adding guest
fn (guest Guest) create_guest_folder () ! {
	folder_path_string := os.dir(@FILE) + '../../../data/guests/${guest.code}_${guest.firstname.replace(' ','')}_${guest.lastname.replace(' ','')}'
	folder_path := pathlib.get(folder_path_string)
	if folder_path.exist != .yes {
		os.mkdir(folder_path.path)!
		// ! creates and writes to readme file might get annoying when reading from folders
		// order_file_path := guest_folder.join('readme.md') or {return error("Failed to create a new readme.md path at: \n$err")}
		// _ = os.create(order_file_path.path)!
		// os.write_file(order_file_path.path, guest.stringify())!
	}
}

fn (db HotelDB) read_guest_folder (mut guest Guest) !Guest {
	folder_path_string := os.dir(@FILE) + '/../../data/guests/${guest.code}_${guest.firstname.replace(' ','')}_${guest.lastname.replace(' ','')}'
	mut folder_path := pathlib.get(folder_path_string)
	file_paths := folder_path.list(pathlib.ListArgs{}) or {return error("Failed to list guest files: $err")}
	mut id_count := 0
	for file_path in file_paths {
		lines_ := os.read_lines(file_path.path) or {return error("Failed to read lines of guest file: $err")}
		lines := lines_.filter(it != '')

		mut path_parts := file_path.path.split('/')
		date_parts := path_parts[path_parts.len-1].trim_string_right('.txt').split('_')
		
		time_of := time.Time{
			year: date_parts[0].int()
			month: date_parts[1].int()
			day: date_parts[2].int()
			hour: date_parts[3].int()
			minute: date_parts[4].int()
			second: date_parts[5].int()
		}

		status := match lines[0].fields()[4] {
			'closed' {Status.closed}
			'open' {Status.open}
			'cancelled' {Status.cancelled}
			else {Status.cancelled}
		}

		mut order := Order {
			id: (db.generate_order_id().int()+id_count).str()
			guest_code: guest.code
			employee_id: lines[0].fields()[3]
			order_time: time_of
			status: status
		}
		
		mut amounts := []finance.Amount{}
		mut medium := ''
		for line in lines {
			fields := line.fields()
			order.product_orders << ProductOrder{
				product_code: fields[0]
				quantity: fields[1].int()
			}
			amounts << db.currencies.amount_get(fields[2]) or {return error("Failed to get amount from line: $err")}
			medium = fields[4]
		}

		order.price = finance.add_amounts(amounts) or {return error("Failed to add amounts: $err")}
		
		if order.product_orders[0].product_code == 'PAY' {

			medium_enum := match medium{
				'cash' {Medium.cash}
				'card' {Medium.card}
				'coupon' {Medium.coupon}
				else {panic("A payment medium in folder '${guest.code}_${guest.firstname}_${guest.lastname}', file '$time_of' has been added incorrectly.")}
			}

			payment := Payment{
				employee_id: order.employee_id
				guest_code: order.guest_code
				amount: order.price
				medium: medium_enum
				time_of: time_of
			}
			guest.payments << payment

			guest.wallet = finance.add_amounts([guest.wallet, payment.amount]) or {return error("Failed to add amounts: $err")}

		} else {
			guest.orders << order
			order.price.val = -order.price.val
			guest.wallet = finance.add_amounts([guest.wallet, order.price]) or {return error("Failed to add amounts: $err")}
			id_count += 1
		}
 		
		
	}
	
	return guest
}
// pub struct Order {
// pub mut:
// 	guest_code string // tbot
// 	employee_id string // tbot
// 	product_orders []ProductOrder // tbot
// 	price finance.Amount
// 	order_time time.Time
// }

// adds a guest from md files / actionparser
pub fn (mut db HotelDB) params_to_guest (mut o params.Params) ! {

	mut new := false
	o.get('wallet') or {new = true}

	email := o.get('email') or {''}
	wallet_string := o.get('wallet') or {'0USD'}
	wallet := db.currencies.amount_get(wallet_string) or {return error("Failed to parse wallet_string: $wallet_string into an amount: $err")}

	hotel_resident := match o.get('hotel') or {'false'} {
		'true' {true}
		else {false}
	}

	code := o.get('code') or {db.generate_guest_code()}

	mut guest := Guest{
		code : code
		firstname : o.get('firstname')!
		lastname : o.get('lastname')!
		email: email
		telegram_username: o.get('telegram_username')!
		wallet: wallet
		hotel_resident: hotel_resident
	}

	if new {
		guest.create_guest_folder() or {return error("Failed to create guest folder: $err")}
	} else {
		db.read_guest_folder(mut guest) or {return error("Failed to read guest folder: $err")}
	}
	
	db.guests << &guest
}

pub fn (db HotelDB) get_guest (code string) !Guest {
	for guest in db.guests {
		if guest.code == code {
			return guest
		}
	}
	return error("Guest code could not be found")
}


pub fn (db HotelDB) guest_exists (code string) bool {
	for guest in db.guests {
		if guest.code == code {
			return true
		}
	}
	return false
}

pub struct Payment {
	employee_id string
	guest_code string
	amount finance.Amount
	medium Medium
	time_of time.Time
}

pub enum Medium {
	card
	cash
	coupon
}

// only accessible by employees
pub fn (mut db HotelDB) take_guest_payment (p Payment) ! {
	mut guest := db.get_guest(p.guest_code) or {return error("Failed to get guest: $err")}
	db.guests = db.guests.filter(it.code != guest.code)
	guest.payments << p
	guest.wallet = finance.add_amounts([guest.wallet, p.amount]) or {return error("Failed to add amounts: $err")}
	guest.log_payment(p.amount, p.medium, p.employee_id)!
	db.guests << guest
}

fn (mut guest Guest) log_payment (amount finance.Amount, medium Medium, employee_id string) ! {
	log_message := 'PAY 1 ${amount.val}${amount.currency.name} $employee_id $medium\n'
	guest.write_to_file(log_message)!
}

fn (mut db HotelDB) charge_guest(mut order Order) ! {
	mut guest := db.get_guest(order.guest_code) or {return error("Failed to get guest: $err")}
	db.guests = db.guests.filter(it.code != guest.code)
	mut price := order.price
	price.val = -price.val
	order.price = price
	guest.wallet = finance.add_amounts([guest.wallet, order.price]) or {return error("Failed to add amounts: $err")}
	guest.orders << order
	db.guests << guest
	db.log_charge(order, guest) or {return error("Failed to log charge")}
}

fn (mut db HotelDB) log_charge (order Order, guest Guest) ! {
	mut log_message := "" 
	for product_order in order.product_orders {
		product := db.get_product(product_order.product_code)!
		log_message += '$product_order.product_code $product_order.quantity ${product.price.val}${product.price.currency.name} $order.employee_id $order.status $product.name\n'
	} 
	guest.write_to_file(log_message)!
}

fn (guest Guest) write_to_file (log_message string) ! {
	order_file_string := os.dir(@FILE) + '/../../data/guests/${guest.code}_${guest.firstname.replace(' ','')}_${guest.lastname.replace(' ','')}/${time_string()}.txt'
	order_file_path := pathlib.get(order_file_string)
	mut order_file := os.create(order_file_path.path) or {return error("Failed to create file $order_file_path.path: $err\n")}
	order_file.writeln(log_message) or {return error("Failed to write to file $order_file_path.path: $err\n")}
	order_file.close()
}

fn (guest Guest) stringify () string {
	text := 'Guest Name: $guest.firstname $guest.lastname
Code: $guest.code
Email: $guest.email
Telegram Username $guest.telegram_username'

	return text
}

fn (db HotelDB) generate_guest_code () string {
	mut guest_codes := []string{}
	for guest in db.guests {
		guest_codes << guest.code
	}
	mut valid := false
	mut code := ''
	for valid == false {
		code = rand.string(4).to_upper()
		if code !in guest_codes {
			valid = true
		}
	}
	return code
}

fn time_string() string {
	return time.now().str().replace(' ', '_').replace(':', '_').replace('-', '_')
}