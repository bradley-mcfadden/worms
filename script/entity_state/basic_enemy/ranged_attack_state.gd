#
# BasicEnemyRangedAttackState is the state the enemy is in while 
# executing a ranged attack. The enemy should leave it when the 
# animation finishes.
#

extends EntityState

class_name BasicEnemyRangedAttackState

const NAME := "RangedAttackState"
const PROPERTIES := {
	color = Color.crimson,
	speed = 350,
	threshold = 200,
	fov = 360,
}

var aplayer: AnimationPlayer


func _init(_fsm: Fsm, _entity: Node) -> void:
	fsm = _fsm
	entity = _entity


func on_enter() -> void:
	aplayer = entity.animation_player
	var _err: int = aplayer.connect("animation_finished", self, "_on_animation_finished")
	aplayer.play("shoot")


func _physics_process(_delta: float):
	pass


func _on_animation_finished(_name) -> void:
	print("Animation finished")
	if fsm.top().NAME == NAME:
		fsm.pop()


func on_exit() -> void:
	aplayer.disconnect("animation_finished", self, "_on_animation_finished")
