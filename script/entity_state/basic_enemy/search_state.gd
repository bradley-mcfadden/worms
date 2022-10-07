#
# BasicEnemySearchState makes the AI randomly walk, until it dies
# or spots an enemy that it should chase.
#

extends EntityState

class_name BasicEnemySearchState

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }

const NAME := "SearchState"
const PROPERTIES := {
	color = Color.green,
	speed = 250,
	threshold = 32,
	fov = 90,
}

const TWO_PI: float = 2 * PI

var noise_location: Vector2
var walk_anim: String
var search_location: Vector2
var search_time: float = -1.0


func _init(_fsm: Fsm, _entity) -> void:
	fsm = _fsm
	entity = _entity


func on_enter() -> void:
	if entity.has_ranged_attack:
		walk_anim = "walk_gun"
	elif entity.has_melee_attack:
		walk_anim = "walk_knife"
	entity.animation_player.play(walk_anim)


func _physics_process(delta: float) -> void:
	var player = entity.check_for_player()
	if player != null:
		fsm.replace(BasicEnemyStateLoader.chase(fsm, entity))
		return

	if noise_location != null:
		fsm.replace(BasicEnemyStateLoader.seek(fsm, entity, noise_location))
		return
	
	if search_time <= 0:
		search_time = rand_range(2.0, 4.0)
		var angle = rand_range(0, TWO_PI)
		var length = rand_range(100, 200)
		search_location = entity.global_position + Vector2.RIGHT.rotated(angle) * length
		print("New search state at ", search_location)
	else:
		search_time -= delta
	
	entity.set_target(search_location)
	var ss = entity.set_interest()
	if ss == SeekState.SEEK_TARGET:
		if entity.animation_player.current_animation != walk_anim:
			entity.animation_player.play(walk_anim)
	else:
		search_time = -1.0

	entity.set_danger()
	entity.choose_direction()
	entity.move(delta)
	

func on_exit() -> void:
	pass


func on_noise_heard(position: Vector2) -> void:
	print("SearchState heard a noise")
	noise_location = position
