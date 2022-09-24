extends EntityState

class_name BasicEnemyMeleeAttackState

const NAME := "MeleeAttackState"
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
	aplayer.play("stab")


func _physics_process(_delta):
	pass


func _on_animation_finished(_name):
	print("Done melee attack")
	if fsm.top().NAME == NAME:
		fsm.pop()


func on_exit():
	entity.end_melee_attack()
	aplayer.disconnect("animation_finished", self, "_on_animation_finished")