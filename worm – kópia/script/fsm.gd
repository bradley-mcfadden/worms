class_name Fsm
extends Object

var stack := []


# push the current state to the top of the stack.
# calls on_exit() for the previous top, and on_enter() for the new state.
# Does not remove the previous state from the stack.
func push(state: EntityState):
	if !stack.empty():
		stack.back().on_exit()
	stack.push_back(state)
	state.on_enter()


# pop the current state from the stack.
# calls on_exit() for the top.
func pop():
	if !stack.empty():
		var current_state = stack.pop_back()
		current_state.on_exit()
		# current_state.queue_free()
	if !stack.empty():
		var new_state = stack.back()
		new_state.on_enter()


# replace the top of the stack with the current state.
# the stack remains the same size.
# on_enter() is called on state, and on_exit() is called for the previous top.
func replace(state: EntityState):
	if !stack.empty():
		stack.pop_back().on_exit()
	stack.push_back(state)
	state.on_enter()


# top of the stack is returned without removing it.
func top() -> EntityState:
	return stack.back() if stack != null else null


func clear():
	stack.clear()
