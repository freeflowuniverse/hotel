module person

import time

struct Person {
	id                string // ? Should this be the main unique identifier or should employees and guests also have unique identifiers?
	firstname         string
	lastname          string
	email             string
	telegram_username string
	phone_number      string
	date_of_birth     time.Time
	allergies         []string
	preferred_contact string
}
