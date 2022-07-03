extends Object

class_name Fsm

var stack := []

# push the current state to the top of the stack.
# calls on_exit() for the previous top, and on_enter() for the new state.
# Does not remove the previous state from the stack.
func push(state:EntityState):
	var current_state = stack.back()
	if current_state != null:
		current_state.on_exit()
	stack.push_back(state)
	state.on_enter()


# pop the current state from the stack.
# calls on_exit() for the top.
func pop():
	var current_state = stack.pop_back()
	if current_state != null:
		current_state.on_exit()
		current_state.queue_free()


# replace the top of the stack with the current state.
# the stack remains the same size.
# on_enter() is called on state, and on_exit() is called for the previous top.
func replace(state:EntityState):
	var current_state = stack.pop_back()
	if current_state != null:
		current_state.on_exit()
	stack.push_back(state)
	state.on_enter()


# top of the stack is returned without removing it.
func top() -> EntityState:
	return stack.back()
