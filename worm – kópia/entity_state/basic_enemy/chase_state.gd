extends EntityState

class_name BasicEnemyChaseState

const NAME := "ChaseState"
const PROPERTIES := {color = Color.crimson, speed = 350, threshold = 200, fov = 360}
# Length of time in seconds before entity will give up its chase
const INITIAL_INTEREST := 10.0

var current_interest
var last_player_location


func _init(_fsm, _entity):
	fsm = _fsm
	entity = _entity


func on_enter():
	current_interest = INITIAL_INTEREST
	last_player_location = entity.position


func _physics_process(delta):
	var player = entity.check_for_player()
	if player != null:
		last_player_location = player.position
		current_interest = INITIAL_INTEREST
		var dist = entity.position.distance_to(player.position) - player.radius - entity.radius
		entity.look_at(player.position)
		if entity.check_melee_attack(dist, player.position):
			print(self, "Doing a melee attack!")
			fsm.push(BasicEnemyStateLoader.melee_attack(fsm, entity))
			return
		if entity.check_ranged_attack(dist, player.position):
			print("Doing a ranged attack!")
			fsm.push(BasicEnemyStateLoader.ranged_attack(fsm, entity))
			return
	# else:
	# 	current_interest -= delta
	# if current_interest < 0:
	# 	fsm.replace(BasicEnemyStateLoader.search(fsm, entity))
	# 	return
	entity.set_target(last_player_location)
	var _ss = entity.set_interest()
	entity.set_danger()
	entity.choose_direction()
	entity.move(delta)


func on_exit():
	pass
