# Explanation

There are four main components to this repository:
- actor_builder
- actors
- library
- src

The actor_builder is a code generation module, it takes the src, a skeleton of the actors and converts it into the fully blown actors, putting the code into the actors directory. Library contains a bunch of standard structs and modules which are used by many different actors.

# Instructions

In order to run the actor_builder, run the go.vsh script which has three constituent parts:
- v run cleanup.vsh, which replaces the old actors directory with the content of src (IMPORTANT NOTE, ANY MODIFICATIONS TO THE ACTORS SHOULD BE WRITTEN IN SRC NOT IN ACTORS)
- v run build.v which converts the skeletons into full actors
- v fmt ./actors beautifies the files, so they are formatted correctly.

Finally, while not completed yet, running import_test.v allows you to see if there are any errors in the actors.



## Interfaces 

- For every actor I have three interfaces, the model interface, the actor interface and the client interface
- the actor interface is required so that methods can be defined on it
- the model interface is necessary so that it can be an importable interface
- the client interface


## Flows
- Bar
- Kitchen

Overlap:
- flows
  - update_catalogue_flow
    - add_product
    - edit_product
  - read_catalogue_flow
  - order_flow
  - cancel_order_flow
    - for both guest and employees
  - update_stocks_flow
  - confirm_order_delivery_flow
- methods
  - get_state
  - get_stock
  - get_stocks
  - add_product
  - edit_product
  - order
  - cancel_order
  - update_stock
  - confirm_order_delivery
