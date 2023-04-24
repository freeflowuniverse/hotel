The actor builder takes a minimal skeleton for an actor, in this case, everything present in the src directory and generates everything else necessary for a fully functioning actor

Necessary Components:
- model.v file which contains the different flavors and data models of an actor
- methods.v file which contains all the non-standard methods (ie excludes basic get/return_state)
- flows.v file (! THIS IS STILL A WORK IN PROGRESS !) which contains the flows

Your directory structure must look as follows:

- kitchen
  - model
    - model.v
  - flows.v
  - methods.v


NOTE! - All functions that should be accessible to other actors in the methods.v file should be prefaced with a pub, all other functions will be treated as utility functions and as such ignored.


DEV STUFF:

I need to be clear about what I get from each file and what I put in each new file

Sequential Steps:
- get core struct from model.v
- add new interface including core struct attributes in model.v (from model.v)
- get public fn declarations from methods.v
- add interface to methods.v (from model.v)
- add standard methods to methods.v (from model.v)
- add boilerplate to actor.v 
- add actor methods to actor.v (from methods.v)
- add standard methods to actor.v (from model.v)
- add interface to actor.v (from model.v)
- add import statements to actor.v (from model.v and methods.v)
- add boiler plate to client.v
- add interface to client.v (from model.v)
- add actor methods to client.v (from methods.v)
- add standard methods to client.v (from methods.v)
- add imports to client.v (from model.v and methods.v)

fn read_update_model
fn read_update_methods 
fn write_actor
fn write_client