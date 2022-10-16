# BasicEnemyPatrolState is a simple state that makes the AI
# target points from an array. Upon reaching a point, the
# AI will target the next one.

extends EntityState

class_name BasicEnemyPatrolState

const NAME := "PatrolState"
const START_REACTION_TIME := 30
const PROPERTIES := {color = Color.aquamarine, speed = 250, threshold = 32, fov = 90}

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }
var reaction_time: float = START_REACTION_TIME
var idle_patrol: Array
var patrol_idx: int
var noise_location = null # Vector2, usually
var walk_anim: String = "walk"
var idle_anim: String = "idle"

func _init(_fsm: Fsm, _entity: Node) -> void:
	fsm = _fsm
	entity = _entity


func on_enter() -> void:
	reaction_time = START_REACTION_TIME
	idle_patrol = entity.idle_patrol
	patrol_idx = entity.patrol_idx
	if entity.has_ranged_attack:
		walk_anim = "walk_gun"
		idle_anim = "idle_gun"
	elif entity.has_melee_attack:
		walk_anim = "walk_knife"
		idle_anim = "idle_knife"
	entity.animation_player.play(walk_anim)
	

func _physics_process(delta: float) -> void:
	if react_to_player():
		fsm.replace(BasicEnemyStateLoader.chase(fsm, entity))
		print("reacted to player")
		return
	if noise_location != null:
		fsm.replace(BasicEnemyStateLoader.seek(fsm, entity, noise_location))
		print("Going to chase noise!")
		return
	entity.set_target(get_target())
	var ss = entity.set_interest()
	if ss == SeekState.REACHED_TARGET or ss == SeekState.NO_TARGET:
		entity.animation_player.play(idle_anim)
	else:
		entity.animation_player.play(walk_anim)
	entity.set_danger()
	entity.choose_direction()
	entity.move(delta)


func react_to_player() -> bool:
	var player = entity.check_for_player()
	if player != null:
		# print(player)
		reaction_time -= 1
		if reaction_time <= 0:
			return true
	return false


func get_target() -> Vector2:
#
# get_target finds the next position to walk towards by consulting an array of
# patrol points. Upon reaching the point, the target index updates.
#
# returns: Point for the AI to seek
	var n = len(idle_patrol)
	if n == 0:
		return entity.global_position
	var threshold = PROPERTIES["threshold"]
	if entity.position.distance_to(idle_patrol[patrol_idx]) < threshold:
		patrol_idx = patrol_idx + 1 if patrol_idx < n - 1 else 0
	return idle_patrol[patrol_idx]


func on_exit() -> void:
	pass


func on_noise_heard(position: Vector2) -> void:
	noise_location = position
