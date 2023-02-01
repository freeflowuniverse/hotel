module hoteldb

import time

import freeflowuniverse.hotel.finance

pub struct ProductOrder {
pub mut:
	product_code string
	quantity int
	note string
}

// an exchange of goods or services with specific magnitude defined
pub struct Order {
pub mut:
	id  string
	guest_code string // tbot
	employee_id string // tbot
	product_orders []ProductOrder // tbot
	price finance.Amount
	order_time time.Time
	status Status
}

pub enum Status {
	open
	closed
	cancelled
}

// todo move note into order and make the third parameter of product_order be the variable price

// called by tbot to add a new order
pub fn (mut db HotelDB) input_order (mut order Order) ! {

	// db.check_guest_exists(order.guest_code)!
	
	mut total_price := db.currencies.amount_get('0usd')!
	for product_order in order.product_orders {
		// also checks that product exists
		mut product_price := db.get_product(product_order.product_code)!.price // ? should get_product return an optional
		product_price.val = product_price.val * product_order.quantity
		total_price = finance.add_amounts([total_price, product_price])!
	}

	order.price = total_price
	order.order_time = time.now()
	order.id = db.generate_order_id()

	// todo move logging of order to after order is confirmed not before

	db.charge_guest(mut order)!
} 

// todo some way to filter for restaurant orders
pub fn (db HotelDB) get_open_orders () !string {
	mut open_orders := []Order{}
	for guest in db.guests {
		open_orders << guest.orders.filter(it.status == .open)
	}
	mut orders_string := 'OPEN ORDERS:\n'
	for order in open_orders {
		mut order_string := '
ID: $order.id
Ordered: ${order.order_time.relative().replace('.','MM')}
'
		for product_order in order.product_orders {
			order_string += ' \\- ${db.get_product(product_order.product_code)!.name} x $product_order.quantity\n'
		}
		order_string += '\n'
		orders_string += order_string
	}
	return orders_string
}

// todo confirm that this is changing the order in db.orders
pub fn (mut db HotelDB) close_order (order_id string) ! {
	println("input order id: $order_id")
	println(typeof(order_id).name)
	for mut guest in db.guests {
		for mut order in guest.orders {
			println("db order id: '$order.id'")
			println(typeof(order.id).name)
			if order.id == order_id {
				db.log_charge(order, guest)!
				order.status = .closed
				return
			}
		}
	}
	return error("Could not find order in db")
}

fn (db HotelDB) generate_order_id () string {
	mut greatest_id := 0
	for guest in db.guests {
		for order in guest.orders {
			if order.id.int() > greatest_id {
				greatest_id = order.id.int()
			}
		}
		}
	return (greatest_id + 1).str()
}


