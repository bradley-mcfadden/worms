extends EntityState


const NAME := "SearchState"
const PROPERTIES := {
	color = Color.green, 
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
