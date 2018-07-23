### todoable

A ruby gem that wraps the todo list API described [here](http://todoable.teachable.tech/#post-lists-id-items)

Still to do:
- Reauthenticate expired token (currently a new token is created for every request).
- Record http transactions using [vcr](https://github.com/vcr/vcrxr) gem (currently tests make real API calls).
- Classes to hold list and item objects.
- Error handling.
- Lots of other refactoring!
