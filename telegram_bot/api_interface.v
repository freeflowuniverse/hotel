module telegram_bot

// CONFIRMED

// TODO
fn (bot TelegramBot) product_exists(product_id string) bool {
	return true
}

// ! DEPRECATED

// TODO 
fn (bot TelegramBot) get_product_name(product_id string) string {
	return "Dummy Name"
}

// TODO 
fn (bot TelegramBot) get_product_ids(product_ids []string) []string {
	return ["D01", "D02"]
}

// TODO 
fn (bot TelegramBot) get_product_names(product_ids []string) []string {
	return ['Dummy Product1', 'Dummy Product2']
}

// TODO 
fn (bot TelegramBot) get_foods(product_ids []string) string {
	return "Dummy Food"
}

// TODO 
fn (bot TelegramBot) get_drinks(product_ids []string) string {
	return "Dummy Drink"
}

// TODO 
fn (bot TelegramBot) get_boats(product_ids []string) string {
	return "Dummy Boat"
}

// TODO 
fn (bot TelegramBot) get_rooms(product_ids []string) string {
	return "Dummy Room"
}

// TODO send customer username
fn (bot TelegramBot) log_purchases(products []ProductOrder) {}

