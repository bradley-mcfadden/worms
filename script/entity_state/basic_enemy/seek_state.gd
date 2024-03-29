#
# BasicEnemySeekState will make the AI go to a particular location.
# Upon seeing an enemy, it will go into a chase state.
# Upon reaching the location, it will go into search state.
#
extends EntityState

class_name BasicEnemySeekState

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }

const NAME := "SeekState"
const PROPERTIES := {
	color = Color.blueviolet,
	speed = 500,
	threshold = 100,
	fov = 90,
}
const CHECK_PLAYER_PERIOD := 0.15
const UPDATE_MOVEMENT_PERIOD := 0.15

var target: Vector2
var walk_anim := "walk"
var idle_anim := "idle"
var noise_location = null # Vector2, usually
var path_graph: PathGraph
var path_target: Vector2 = Vector2.ZERO
var path: Array = []
var path_idx: int = -1
var check_player_dx := 0.0
var update_movement_dx := UPDATE_MOVEMENT_PERIOD


func _init(_fsm: Fsm, _entity: Node, _target: Vector2, _path_graph: PathGraph) -> void:
	fsm = _fsm
	entity = _entity
	target = _target
	path_graph = _path_graph


func on_enter() -> void:
	if entity.has_ranged_attack:
		walk_anim = "walk_gun"
		idle_anim = "idle_gun"
	elif entity.has_melee_attack:
		walk_anim = "walk_knife"
		idle_anim = "idle_knife"

	var space = entity.get_world_2d().direct_space_state
	if path_graph != null:
		var from: int = path_graph.closest_unobs_to_id(entity.global_position, entity.collision_mask)
		var to: int = path_graph.closest_unobs_to_id(target, entity.collision_mask)

		# Check that current position to from is unobstructed
		# Check that 'to' and path_target is unobstructed
		var from_pt: Vector2 = path_graph.astar.get_point_position(from)
		var to_pt: Vector2 = path_graph.astar.get_point_position(to)
		var from_collision: Dictionary = space.intersect_ray(entity.global_position, from_pt, [], entity.collision_mask)
		var to_collision: Dictionary = space.intersect_ray(to_pt, path_target, [], entity.collision_mask)
		if (!(from_collision.has("collider") and from_collision["collider"] is StaticBody2D)
			and !(to_collision.has("collider") and to_collision["collider"] is StaticBody2D)):	
			print(entity, " Moving between %d to %d" % [from, to])
			path = path_graph.astar.get_point_path(from, to)
			print("My path is ", path)
			path.append(target)
			path_idx += 1
			path_target = path[path_idx]
		else:
			print("Seek state could not find a path to the location")
			fsm.replace(BasicEnemySearchState.new(fsm, entity))
	else:
		fsm.replace(BasicEnemySearchState.new(fsm, entity))


func _physics_process(delta: float) -> void:
	check_player_dx += delta
	if check_player_dx >= CHECK_PLAYER_PERIOD:
		check_player_dx = 0.0
		var player = entity.check_for_player()
		if player != null:
			if entity.has_ranged_attack or entity.has_melee_attack:
				fsm.replace(BasicEnemyStateLoader.chase(fsm, entity))
			else:
				fsm.replace(BasicEnemyStateLoader.fear(fsm, entity))
			return
	if noise_location != null:
		fsm.replace(BasicEnemyStateLoader.seek(fsm, entity, noise_location, path_graph))
		print("Going to chase noise!")
		noise_location = null
		return
	if path_target != Vector2.ZERO:
		entity.set_target(path_target)
	else:
		entity.set_target(target)

	update_movement_dx += delta
	if update_movement_dx >= UPDATE_MOVEMENT_PERIOD:
		update_movement_dx = 0.0
		var ss = entity.set_interest()
		if ss == SeekState.SEEK_TARGET:
			if entity.animation_player.current_animation != walk_anim:
				entity.animation_player.play(walk_anim)
		elif ss == SeekState.REACHED_TARGET:
			path_idx += 1
			if path_idx < len(path):
				path_target = path[path_idx]
				print("Going to ", path_target, " idx ", path_idx)
		else:
			if entity.animation_player.current_animation != idle_anim:
				entity.animation_player.play(idle_anim)
				fsm.replace(BasicEnemySearchState.new(fsm, entity))
				return
		
		entity.set_danger()
		entity.choose_direction()
	entity.move(delta)


func on_exit() -> void:
	pass


func on_noise_heard(position: Vector2) -> void:
	print("SeekState heard a noise")
	noise_location = position
