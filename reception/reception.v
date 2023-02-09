module reception

import library.common

struct Reception {
	id string
	complaints map[string]common.Message
}

// Create Guest
// creates a new guest
// FROM USESR
fn (reception Reception) create_guest () ! {
	
}

// Check in guest
// FROM USER
fn (reception Reception) check_in_guest () ! {
	
}

// Check out guest
// FROM USER OR INTERNAL
fn (reception Reception) check_out_guest () ! {
	
}

// Respond to complaint
// FROM USER
fn (reception Reception) respond_to_complaint () ! {

}

// Expose complaint
// TO USER
fn (mut reception Reception) expose_complaint () ! {

}