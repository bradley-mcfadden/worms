# 
# fear_state.gd
# When in this state, the enemy should run away from the player.
#
extends EntityState

class_name BasicEnemyFearState

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }

const NAME := "FearState"
const PROPERTIES := {
	color = Color.blue,
	speed = 750,
	threshold = 20,
	fov = 360,
}
const FEAR_TIME := 10.0
const ACQUIRE_TIMEOUT := 1.0
const CHECK_PLAYER_PERIOD := 0.25

var interest := FEAR_TIME
var acquire_ctr := 0.0
var last_player_location: Vector2 = Vector2.ZERO
var walk_anim := "walk"
var idle_anim := "idle"
var check_player_dx := CHECK_PLAYER_PERIOD

func _init(_fsm: Fsm, _entity: Node) -> void:
	fsm = _fsm
	entity = _entity
	if entity.has_ranged_attack:
		walk_anim = "walk_gun"
		idle_anim = "idle_gun"
	elif entity.has_melee_attack:
		walk_anim = "walk_knife"
		idle_anim = "idle_knife"


# on_enter calls code once when switching to this state
func on_enter() -> void:
	print(self, " Entering fear state!")


# called every _physics_process in parent
func _physics_process(delta: float) -> void:
	check_player_dx += delta
	if check_player_dx >= CHECK_PLAYER_PERIOD:
		check_player_dx = 0.0
		var player = entity.check_for_player()
		if player != null:
			if acquire_ctr <= 0.0:
				last_player_location = player.global_position
				interest = FEAR_TIME
				acquire_ctr = ACQUIRE_TIMEOUT
			else:
				acquire_ctr -= delta
		else:
			interest -= delta
			if interest < 0:
				fsm.replace(BasicEnemyStateLoader.patrol(fsm, entity))
	
	var dir_player_to_me: Vector2 = entity.global_position - last_player_location	
	var fear_target := dir_player_to_me.normalized().rotated(randf() - 0.5) * 100.0
	# print("Running away to ", fear_target)
	entity.set_target(entity.global_position + fear_target)
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


# on_exit is called when switching out of this state
func on_exit() -> void:
	pass
