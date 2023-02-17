module guest

import freeflowuniverse.hotel.library.person
import freeflowuniverse.hotel.library.common


// todo change maps to lists

pub struct Guest {
person.Person
pub mut:
	orders  []common.Order // string is id of order
	assistance_requests []common.AssistanceRequest  // string is id
	code    string
}
