extends EntityState

class_name BasicEnemyRangedAttackState

const NAME := "RangedAttackState"
const PROPERTIES := {
	color = Color.crimson,
	speed = 350,
	threshold = 200,
	fov = 360,
}

var aplayer


func _init(_fsm, _entity):
	fsm = _fsm
	entity = _entity


func on_enter():
	aplayer = entity.animation_player
	aplayer.connect("animation_finished", self, "_on_animation_finished")
	aplayer.play("shoot")


func _physics_process(_delta):
	pass


func _on_animation_finished(_name):
	print("Animation finished")
	if fsm.top().NAME == NAME:
		fsm.pop()


func on_exit():
	aplayer.disconnect("animation_finished", self, "_on_animation_finished")
