extends EntityState

class_name PatrolState

const START_REACTION_TIME := 30

var reaction_time = START_REACTION_TIME
var idle_patrol 
var patrol_idx
var properties


func _init(p_fsm, p_entity):
	fsm = p_fsm
	entity = p_entity


func on_enter():
	reaction_time = START_REACTION_TIME
	idle_patrol = entity.idle_patrol
	patrol_idx = entity.patrol_idx
	properties = entity.ent_state_prop[typeof(self)]


func _physics_process(_delta):
	if react_to_player():
		#fsm.push()
		return
	entity.set_target(get_target())
	entity.set_danger()
	entity.choose_direction()
	entity.move()


func react_to_player() -> bool:
	var player = entity.check_for_player()
	if player != null:
		reaction_time -= 1
		if reaction_time <= 0:
			return true
	return false


func get_target():
	var n = len(idle_patrol)
	if n == 0: return null
	var threshold = properties["threshold"]
	if entity.position.distance_to(idle_patrol[patrol_idx]) < threshold:
		patrol_idx = patrol_idx + 1 if patrol_idx  < n - 1 else 0
	return idle_patrol[patrol_idx]


func on_exit():
	pass
