Every function is in one of three categories:
- FROM USER
- TO USER
- INTERNAL
- SUPPORT (used in other functions)

actor_id should be the name of the actor ie bar, kitchen, maintenance, accounting
instance_id should be a number ie 4, 26, 43

## Schema Methodology
- We need a heirarchy of actors
- every actor should have an internal state ie which structs 
- every actor should have a list of functions
- every actor should have a defined set of inputs and outputs with reference to the functions


# RESOLUTION TO PARAMETER OVERLAP ISSUE
- an actor responding to a message should have a function for every message it can receive from other actors and they are in an anonymous imported struct that only has methods ie

import library.accounting

struct Accounting {
AccountingBase
accounting.person.PersonRequests
accounting.department.DepartmentRequests
accounting.interface.InterfaceRequests
}

// empty struct with just methods
struct PersonRequests {}


# make booking guest example

import library.guest

struct Guest {
person.Person
mut:
    id string
}

type Booking = guest.RoomBooking | guest.SpaBooking | guest.BoatBooking

fn (mut guest Guest) request_booking_availability (actor_name string) ! {
    action := 'hotel.$actor_name.return_booking_availability'
}

fn (mut guest Guest) request_booking_availability (booking Booking) ! {
    
}

// library/common.v

import time

struct Booking {
    id string
    name string
    product_code string
    start time.Time
    duration time.Time
    total_price finance.Price library.Price
    note string
}

struct Purchase {
    id string
    name string
    product_code string
    total_price library.Price
    delivery_time time.Time
    note string
    quantity int
    unit Unit
}

struct Product {
    product_code string
    name string
    state State
    price library.Price
    unit Unit
}


// library/guest.v

struct RoomBooking {
Booking 
    room_nr  string
    breakfast bool
    people  int
}


# Product Codes

a product code should have two parts, the actor character A-Z and the two-digit product code(unique per actor, but not domain unique) ie R21, A03, H84

# Library Structure

library
- department
- interface
- accounting
  - 
- guest
  - restaurant
    - FoodOrder


library
- actor
  - actor
    - all the methods and mixins of that actor 

# expose functions

all functions that begin with the phrase expose are designed to send a message to the user