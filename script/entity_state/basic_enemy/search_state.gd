extends EntityState

class_name BasicEnemySearchState

const NAME := "SearchState"
const PROPERTIES := {
	color = Color.green,
	speed = 350,
	threshold = 200,
	fov = 360,
}


var noise_location = null


func _init(_fsm, _entity):
	fsm = _fsm
	entity = _entity


func on_enter():
	pass


func _physics_process(_delta):
	if noise_location != null:
		fsm.replace(BasicEnemyStateLoader.seek(fsm, entity, noise_location))


func on_exit():
	pass


func on_noise_heard(position: Vector2):
	print("SearchState heard a noise")
	noise_location = position
