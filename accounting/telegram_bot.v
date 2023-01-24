module accounting

import telegram_bot
// This file is the serializer/deserializer

// Receive Telegram Messages

fn (tbot telegram_bot.TelegramBot) function () ! {
	tbot.client.send_job("stuff")
}

// Send Telegram Messages

fn (tbot telegram_bot.TelegramBot) function () ! {
	tbot.bot.send_message("stuff")
}


// Response to callback message