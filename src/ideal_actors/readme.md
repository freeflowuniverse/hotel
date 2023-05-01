Responsibilities of the different actors

Supervisor:
- to create new actors
- to give addresses of actors from their actor name and id (should these all be plural ie you always give a list of ids, which could be of length one)
- to give all addresses of a certain actor type


User:
- to modify its own state (edit)
- to be deleted (delete)
- to identify itself given a unique attribute (find)
- to return itself (get) //! somewhat redundant with find
- return an attribute with filters
- check in // Custom
- check out // Custom
- register guest // Custom

Kitchen:
- edit/delete/find/get/get_attributes
- order // Custom
- order_history // Custom

What needs to be defined for each actor:
- model 
- unique attributes in core
- which attributes can be accessed by who // Stage 2 (this can be done with an access right struct, but I will need to figure out authentication first)
- custom methods

struct AccessRights {
    attribute_name string

}

MAIN ISSUES:
- The aggregate data across actors issue
  - validation of unique data across actors
- The referencing of data issue
- authentication of access


ACTOR BUILDER COMPONENTS:
- create struct (name, attributes) string, imports
- create interface (name, attributes) string, imports
- create function (receiver, name, inputs, outputs, return_type, ...body) string, imports
- create import

Different types of functions:
- custom methods
  - actor, client
- standard methods
  - methods, actor, client
