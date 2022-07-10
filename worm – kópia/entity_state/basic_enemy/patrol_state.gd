extends EntityState

class_name BasicEnemyPatrolState

const NAME := "PatrolState"
const START_REACTION_TIME := 30
const PROPERTIES := {color = Color.aquamarine, speed = 250, threshold = 32, fov = 90}

var reaction_time = START_REACTION_TIME
var idle_patrol 
var patrol_idx

func _init(_fsm, _entity):
	fsm = _fsm
	entity = _entity


func on_enter():
	reaction_time = START_REACTION_TIME
	idle_patrol = entity.idle_patrol
	patrol_idx = entity.patrol_idx


func _physics_process(delta):
	if react_to_player():
		fsm.replace(BasicEnemyStateLoader.chase(fsm, entity))
		print("reacted to player")
		return
	entity.set_target(get_target())
	var _ss = entity.set_interest()
	entity.set_danger()
	entity.choose_direction()
	entity.move(delta)


func react_to_player() -> bool:
	var player = entity.check_for_player()
	if player != null:
		print(player)
		reaction_time -= 1
		if reaction_time <= 0:
			return true
	return false


func get_target():
	var n = len(idle_patrol)
	if n == 0: return null
	var threshold = PROPERTIES["threshold"]
	if entity.position.distance_to(idle_patrol[patrol_idx]) < threshold:
		patrol_idx = patrol_idx + 1 if patrol_idx  < n - 1 else 0
	return idle_patrol[patrol_idx]


func on_exit():
	pass
