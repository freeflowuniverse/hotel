This module reads in the files for an actor and generates the client through which the actor can be interacted with.

However, for that to work there are certain standard formats that must be followed:
- supervisor router function must be named 'handle_job'
- match function with 'handle_job' function must use the phrase 'match actionname {' in its first line

TODO: 
- [x] read supervisor methods
- [x] test above
- [ ] read flow methods
- [ ] test above
- [x] write supervisor methods
- [x] test above
- [ ] write flow methods
- [ ] test above