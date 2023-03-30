module accounting

// TODO this doesnt work, cant define methods on an imported struct

import telegram_bot
// This file is the serializer/deserializer


// Receive Telegram Messages

// Sample receive telegram message function
fn (tbot telegram_bot.TelegramBot) function () ! {
	tbot.client.send_job("stuff")
}


// Send Telegram Messages

// Sample send telegram message function
fn (tbot telegram_bot.TelegramBot) function () ! {
	tbot.bot.send_message("stuff")
}


// Response to callback message