extends EntityState

class_name RangedAttackState


const NAME := "RangedAttackState"
const PROPERTIES := {
	color = Color.crimson, 
	speed = 350, 
	threshold = 200, 
	fov = 360,
}


func _init(_fsm, _entity):
	fsm = _fsm
	entity = _entity


func on_enter():
	pass


func _physics_process(_delta):
	pass


func on_exit():
	pass
