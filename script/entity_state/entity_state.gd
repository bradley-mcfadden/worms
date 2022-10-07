#
# Base class for an enemy state.
# Pushed or popped from a finite state machine.
#
extends Object

class_name EntityState

var entity: Node
var fsm # Fsm

# Executed when the state enters the top of the FSM
func on_enter():
	pass


# Executed every physics frame while the state is on the top of the FSM
func _physics_process(_delta):
	pass


# Execute when the state is no longer on the top of the FSM
func on_exit():
	pass
