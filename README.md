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

## Message Objects
- Transaction - Financial transaction of money
- Product - a product of some sort ie food, boat, USD (every product has USD value)
- Amount - a certain amount
- Information - simple text field
- TimePeriod - a start and end date where the end date is optional
- Budget?