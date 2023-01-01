# BasicEnemyDeadState is an idle state. All it should do is play
# the entity's death animation, then idle forever.
extends EntityState

class_name BasicEnemyDeadState

const NAME := "DeadState"
const PROPERTIES := {color = Color.black, speed = 0, threshold = 0, fov = 0}


func _init(_fsm: Fsm, _entity: Node) -> void:
	fsm = _fsm
	entity = _entity


func on_enter() -> void:
	entity.animation_player.play("gib")
	entity.get_node("BloodExplode").emitting = true
	entity.get_parent().move_child(entity, 0)
	entity.call_deferred("set_monitoring", false)
	entity.call_deferred("set_monitorable", false)


func _physics_process(_delta: float) -> void:
	pass


func on_exit() -> void:
	pass
