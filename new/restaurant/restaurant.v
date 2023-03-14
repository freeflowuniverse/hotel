module restaurant

// ui can be included but only for one-off sending of messages
fn (restaurant Restaurant) order (order Order) ! {
	restaurant.orders << order

	mut ui := ui_client.new(restaurant.chef_channel, restaurant_id)

	message := 'order: $order'

	ui.send_message(message)
}