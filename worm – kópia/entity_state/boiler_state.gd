# Boiler plate code for an entity state.
# Each of these fields and methods needs to be present in a class that
# extends EntityState. 
# Depending on the entity, the properties keys can be swapped.
extends EntityState


class_name BoilerState


const NAME := "BoilerState"
const PROPERTIES := {
	color = Color.crimson, 
	speed = 350, 
	threshold = 200, 
	fov = 360,
}


func _init(_fsm, _entity):
	fsm = _fsm
	entity = _entity


# on_enter calls code once when switching to this state
func on_enter():
	pass


# called every _physics_process in parent
func _physics_process(_delta):
	pass


# on_exit is called when switching out of this state
func on_exit():
	pass
