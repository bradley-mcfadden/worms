# BasicEnemyMeleeAttackState is the state the entity is in while it does
# a melee attack. It transitions out of the state immediately afterward.
extends EntityState

class_name BasicEnemyMeleeAttackState

const NAME := "MeleeAttackState"
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
	aplayer.connect("animation_finished", self, "_on_animation_finished")
	aplayer.play("stab")


func _physics_process(_delta: float) -> void:
	pass


func _on_animation_finished(_name: String) -> void:
	print("Done melee attack")
	if fsm.top().NAME == NAME:
		fsm.pop()


func on_exit() -> void:
	entity.end_melee_attack()
	aplayer.disconnect("animation_finished", self, "_on_animation_finished")
