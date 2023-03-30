module flows

import freeflowuniverse.crystallib.ui
import freeflowuniverse.hotel.library.common
import freeflowuniverse.hotel.library.finance
import freeflowuniverse.baobab.jobs { ActionJob }
import freeflowuniverse.baobab.client
import freeflowuniverse.hotel.library.flow_methods { ViewCatalogueMixin }

import time

// struct GuestFlows {
// ViewCatalogueMixin
// 	baobab client.Client
// }

struct Guest {
mut:
	firstname string
	lastname string
	email string
	telegram string
	code string
	baobab &client.Client
}






