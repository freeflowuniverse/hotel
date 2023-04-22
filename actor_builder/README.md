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