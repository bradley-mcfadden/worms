#
# Fsm is a finite state machine that allows for different behaviour to be 
# applied to a particular scene.
# 
class_name Fsm
extends Object

var stack := []


func push(state) -> void: # push(EntityState) -> void
# push the current state to the top of the stack.
# calls on_exit() for the previous top, and on_enter() for the new state.
# Does not remove the previous state from the stack.
	if !stack.empty():
		stack.back().on_exit()
	stack.push_back(state)
	state.on_enter()


func pop() -> void: # pop() -> void
# pop the current state from the stack.
# calls on_exit() for the top.
	if !stack.empty():
		var current_state = stack.pop_back()
		current_state.on_exit()
		# current_state.queue_free()
	if !stack.empty():
		var new_state = stack.back()
		new_state.on_enter()


func replace(state) -> void: # replace(EntityState) -> void
# replace the top of the stack with the current state.
# the stack remains the same size.
# on_enter() is called on state, and on_exit() is called for the previous top.
	if !stack.empty():
		stack.pop_back().on_exit()
	stack.push_back(state)
	state.on_enter()


func top(): # top() -> EntityState
# top of the stack is returned without removing it.
	if stack != null:
		if not stack.empty():
			return stack.back()

	return null


func clear() -> void:
# clear remove all the state from the FSM.
	stack.clear()
