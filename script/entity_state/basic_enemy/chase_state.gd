extends EntityState

class_name BasicEnemyChaseState

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }

const NAME := "ChaseState"
const PROPERTIES := {color = Color.crimson, speed = 350, threshold = 200, fov = 360}
# Length of time in seconds before entity will give up its chase
const INITIAL_INTEREST := 1.0

var current_interest
var last_player_location
var walk_anim := "walk"
var idle_anim := "idle"


func _init(_fsm, _entity):
	fsm = _fsm
	entity = _entity


func on_enter():
	current_interest = INITIAL_INTEREST
	last_player_location = entity.position
	if entity.has_ranged_attack:
		walk_anim = "walk_gun"
		idle_anim = "idle_gun"
	elif entity.has_melee_attack:
		walk_anim = "walk_knife"
		idle_anim = "idle_knife"
	


func _physics_process(delta):
	var player = entity.check_for_player()
	if player != null:
		last_player_location = player.global_position
		current_interest = INITIAL_INTEREST
		var dist = entity.global_position.distance_to(player.global_position) - player.radius - entity.radius
		if entity.check_melee_attack(dist, player.global_position):
			print("Doing a melee attack!")
			fsm.push(BasicEnemyStateLoader.melee_attack(fsm, entity))
			return
		if entity.check_ranged_attack(dist, player.global_position):
			print("Doing a ranged attack!")
			fsm.push(BasicEnemyStateLoader.ranged_attack(fsm, entity))
			return
	
	else:
		current_interest -= delta
		if current_interest < 0.0:
			print("Switch to search state")
			fsm.replace(BasicEnemyStateLoader.search(fsm, entity))
			return
	entity.set_target(last_player_location)
	var ss = entity.set_interest()
	if ss == SeekState.SEEK_TARGET:
		if entity.animation_player.current_animation != walk_anim:
			entity.animation_player.play(walk_anim)
	else:
		if entity.animation_player.current_animation != idle_anim:
			entity.animation_player.play(idle_anim)

	entity.set_danger()
	entity.choose_direction()
	entity.move(delta)


func on_exit():
	pass
