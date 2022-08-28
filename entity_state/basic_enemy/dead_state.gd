extends EntityState

class_name BasicEnemyDeadState

const NAME := "DeadState"
const PROPERTIES := {color = Color.black, speed = 0, threshold = 0, fov = 0}


func _init(_fsm, _entity):
	fsm = _fsm
	entity = _entity


func on_enter():
	pass


func _physics_process(_delta):
	pass


func on_exit():
	pass
