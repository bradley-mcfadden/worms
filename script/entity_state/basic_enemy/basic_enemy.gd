#
# basic_enemy.gd
# Controls the enemies of the game, and handles enemies taking damage, dieing,
# pathfinding, etc.
#

tool
extends Area2D

class_name BasicEnemy

# Emitted when the enemy has a bullet that should attach to the level.
signal bullet_created(bullet) # instance of bullet.tscn
# Emitted when the enemy dies.
signal died(node, from, overkill) # BasicEnemy instance, node, bool
# Emitted when the enemy produces a noise
#warning-ignored:unused-signal
signal noise_produced(position, audible_radius) # Vector2, float

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }

const DRAW_ME := false

export(int) var radius := 20
export(float) var steer_force := 0.5
export(int) var look_ahead := 125
export(int) var num_rays := 12
export(PoolVector2Array) var idle_patrol := PoolVector2Array()
export(float) var fov := 90.0
export(int) var look_distance := 300
export(int) var reaction_time = 12
export(bool) var has_ranged_attack := true
export(bool) var has_melee_attack := false
export(int) var ranged_damage := 20
export(int) var melee_damage := 50
export(PackedScene) var bullet
export(int) var start_health := 100
export(int) var hear_radius := 2000
export var melee_thresh := 50
export var ranged_thresh := 300
export var layer := 0

# context array
var ray_directions := []
var interest := []
var danger := []
var chosen_dir := Vector2.ZERO
var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO
var patrol_idx := 0
var target = null # Usually a Vector2, sometimes null
var rot: float = 0
var start_transform
var start_layer
var health: int = start_health
var is_hidden: bool
var fsm # Fsm
var animation_player: AnimationPlayer
var ent_state_prop := {}


func _ready() -> void:
	set_layer(layer)
	if Engine.editor_hint:
		return

	animation_player = $AnimationPlayer
	$AnimationPlayer.play("idle")
	num_rays += 1
	fov = deg2rad(fov)

	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	var angle_step = 3 * PI / 2 / (num_rays - 1)
	for i in num_rays:
		var angle = i * angle_step - 3 * PI / 4
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		if angle > PI / 2 or angle < 3 * PI / 2:
			ray_directions[i] *= 0.5

	start_transform = transform
	start_layer = layer

	fsm = Fsm.new()
	fsm.push(BasicEnemyStateLoader.patrol(fsm, self))

	ent_state_prop[BasicEnemyPatrolState.NAME] = BasicEnemyPatrolState.PROPERTIES
	ent_state_prop[BasicEnemyChaseState.NAME] = BasicEnemyChaseState.PROPERTIES
	ent_state_prop[BasicEnemyDeadState.NAME] = BasicEnemyDeadState.PROPERTIES
	ent_state_prop[BasicEnemyMeleeAttackState.NAME] = BasicEnemyMeleeAttackState.PROPERTIES
	ent_state_prop[BasicEnemyRangedAttackState.NAME] = BasicEnemyRangedAttackState.PROPERTIES
	ent_state_prop[BasicEnemySearchState.NAME] = BasicEnemySearchState.PROPERTIES
	ent_state_prop[BasicEnemySeekState.NAME] = BasicEnemySeekState.PROPERTIES
	ent_state_prop[BasicEnemyFearState.NAME] = BasicEnemyFearState.PROPERTIES
	# ent_state_prop[typeof(MeleeAttackState)] = MeleeAttackState.PROPERTIES
	# ent_state_prop[typeof(RangedAttackState)] = RangedAttackState.PROPERTIES

	if has_ranged_attack:
		ent_state_prop[BasicEnemyChaseState.NAME]["threshold"] = ranged_thresh
	else:
		ent_state_prop[BasicEnemyChaseState.NAME]["threshold"] = melee_thresh


func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	var current_estate = fsm.top()
	if current_estate != null:
		current_estate._physics_process(delta)


func move(delta: float) -> void:
#
# move
# Move the enemy toward its target.
# delta - Time since last frame, useful for scaling movement speed.
# 
	var reached_target: bool = target.distance_to(global_position) < fsm.top().PROPERTIES["threshold"]
	if is_hidden and !fsm.top().NAME == BasicEnemyDeadState.NAME and not reached_target:
		$echo.set_visible(true)
	else:
		$echo.set_visible(false)
	if (target == null or reached_target):
		return
	var speed = fsm.top().PROPERTIES["speed"]
	var desired_velocity = chosen_dir.rotated(rot) * speed
	velocity = velocity.linear_interpolate(desired_velocity, steer_force)
	rotation = velocity.angle()
	position += velocity * delta


func _draw() -> void:
	if not DRAW_ME or fsm == null:
		return
	var current_state = fsm.top()
	if current_state == null:
		return
	var prop = current_state.PROPERTIES
	var state = current_state.NAME
	var color = prop["color"]
	draw_arc(Vector2.ZERO, 20, 0, PI * 2, 20, color)
	draw_line(Vector2.ZERO, Vector2(20, 0), color)
	var f = deg2rad(prop["fov"])
	if !Engine.editor_hint:
		match state:
			BasicEnemySeekState.NAME:
				continue
			BasicEnemyPatrolState.NAME:
				_draw_semicircle(look_distance, f, Color.black)
			BasicEnemyChaseState.NAME:
				_draw_semicircle(look_distance, f, Color.black)
				_draw_semicircle(melee_thresh, f, Color.black)
				_draw_semicircle(ranged_thresh, f, Color.black)
	else:
		if len(idle_patrol) > 0:
			_draw_polyline(idle_patrol, Color.black, transform.affine_inverse())
		_draw_semicircle(look_distance, f, Color.black)
		if has_melee_attack:
			_draw_semicircle(melee_thresh, f, Color.black)
		if has_ranged_attack:
			_draw_semicircle(ranged_thresh, f, Color.black)

		_draw_polyline(idle_patrol, Color.black, transform.affine_inverse())


# draw a semicircle with radius, which travels around the arc for f,
# and is color color
func _draw_semicircle(rradius: float, f: float, color: Color) -> void:
	var f2 = f / 2
	var cosf2 = cos(f2)  # cos(x) = -cos(x)
	var sinf2 = sin(f2)  # sin(-x) = -sin(x)
	draw_arc(Vector2.ZERO, rradius, -f2, f2, 20, color)
	draw_line(Vector2(20 * cosf2, 20 * -sinf2), Vector2(rradius * cosf2, rradius * -sinf2), color)
	draw_line(Vector2(20 * cosf2, 20 * sinf2), Vector2(rradius * cosf2, rradius * sinf2), color)


func _draw_polyline(points: Array , color: Color, xform: Transform2D) -> void:
#
# _draw_polyline
# Draw a polygon.
# points - Vertices of the polygon
# color - Color to draw the line of the polygon
# xform - Local to world transform matrix
# 
	var p2 := []
	for p in points:
		p2.append(xform * p)
	p2.append(p2.front())
	draw_polyline(p2, color)


func _process(_delta: float) -> void:
	update()


func reset() -> void:
#
# reset the enemy to its initial state.
# 
	# context array
	chosen_dir = Vector2.ZERO
	velocity = Vector2.ZERO
	acceleration = Vector2.ZERO
	patrol_idx = 0
	fsm.clear()
	fsm.push(BasicEnemyStateLoader.patrol(fsm, self))
	target = null
	rot = 0
	transform = start_transform
	health = start_health
	set_layer(start_layer)
	$MeleeAttack.visible = false
	$MeleeAttack.monitoring = false


func set_interest() -> Object: # Return SeekState
#
# set_interest
# Set the enemy's intereset in moving in each direction indicated by ray_directions.
# Used to prevent the enemy from walking into walls.
# See Context-based steering.
# return - State of player's travel to its target.
#
	if target == null:
		# print("null target")
		set_default_interest()
		return SeekState.NO_TARGET
	var threshold = ent_state_prop[fsm.top().NAME]["threshold"]
	if position.distance_to(target) < threshold:
		return SeekState.REACHED_TARGET
	var path_direction = target - position
	rot = path_direction.angle()
	for i in num_rays:
		var d = ray_directions[i].rotated(rot).dot(path_direction)
		interest[i] = max(0, abs(d))
	# If no world path, use default interest
	# else:
	# 	set_default_interest()

	return SeekState.SEEK_TARGET


func set_default_interest() -> void:
#
# set_default_intereset
# Default to moving forward
#
	for i in num_rays:
		var d = ray_directions[i].rotated(rot).dot(transform.x)
		interest[i] = max(0, d)


func set_danger() -> void:
#
# set_danger
# Cast rays in several directions to check for collisions.
# This data can be used to avoid walls later.
#
	var space_state := get_world_2d().direct_space_state
	for i in num_rays:
		var result := space_state.intersect_ray(
			position,
			position + ray_directions[i].rotated(rot) * look_ahead,
			[self],
			collision_layer
		)
		if result:
			danger[i] = 1.0  #- result.position.distance_to(position) / look_ahead
		else:
			danger[i] = 0.0


func choose_direction() -> void:
#
# choose_direction
# Given result of set_danger, weight direction of movement toward 
# a path with the fewest amount of obstacles.
#
	# Eliminate interest in slots with danger
	for i in num_rays:
		# if danger[i] > 0.0:
		# 	interest[i] = 0.0
		interest[i] = max(0.0, 1.0 - danger[i])
	# Choose direction based on remaining interest
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()


func set_target(_target) -> void: # Target is either null or a Vector2
#
# set_target that the player should pursue.
# _target - Location for the player to pursue. May be null.
#
	target = _target


# check for the player, and if we find an active player in the field of view,
# acquire it as target and reduce our reaction time
func check_for_player() -> Node:
#
# check_for_player
# Check for close players are, and if any player is in the detection area (a cone)
# return - Acquired player, or null if nothing in range
#
	if not get_parent().has_method("get_players"):
		return null
	var players = get_parent().get_players()
	var min_dist := 200000.0
	var closest_ent: Node = null
	# Prefer finding a player
	var space_state = get_world_2d().direct_space_state
	for player in players:
		var entities: Array = player.get_entity_positions()
		if !player.is_alive():
			continue
		for ent in entities:
			if ent == null:
				continue
			var position_diff = ent.global_position - global_position
			var angle_to_player = abs((position_diff).angle() - rotation)
			var dist_to_player = position_diff.length() - ent.radius - radius
			var f = deg2rad(fsm.top().PROPERTIES["fov"])
			var hit = space_state.intersect_ray(
				global_position, global_position + (position_diff).normalized() * look_distance, [self],
				collision_mask
			)
			#if hit.has("collider"):
			#	print(hit)
			if (
				angle_to_player < f * 0.5
				#and 
				and ent.get_layer() == get_layer()
				# and dist_to_player < look_distance
				and ent.is_alive()
			
				and hit.has("collider")
				and hit["collider"].has_method("take_damage")			
			):
				if dist_to_player < min_dist:
					min_dist = dist_to_player
					closest_ent = ent
	return closest_ent


func check_ranged_attack(_dist_to_player: float, ppos: Vector2) -> bool:
#
# check_ranged_attack
# Check if a ranged attack would be successful.
# _dist_to_player - Separation between self and player.
# ppos - Player position
# return - True if a ranged attack would probably succeed.
# 
	if !has_ranged_attack:
		return false
	var space_state = get_world_2d().direct_space_state
	var hit: Dictionary = space_state.intersect_ray(global_position, global_position+(ppos-global_position)*fsm.top().PROPERTIES["threshold"], [self], collision_mask)
	if hit.has("collider"):
		if hit["collider"].has_method("take_damage"):
			# print("Doing ranged attack!")
			look_at(hit["position"])
			return true
	return false


func start_ranged_attack() -> void:
#
# start_ranged_attack
# Start the ranged attack animation, and transition to a new state.
# 
	# launch a projectile
	var new_bullet = bullet.instance()
	new_bullet.setup(
		self, Vector2.RIGHT.rotated(rotation) * 1000, ranged_damage, 10, collision_layer, layer
	)
	new_bullet.position = $MuzzleFlash.global_position
	new_bullet.rotation = (target - global_position).angle()
	emit_signal("bullet_created", new_bullet)
	$Sounds/GunShot.play()


func end_ranged_attack() -> void:
#
# end_ranged_attack
# Called when a ranged attack has finished.
# 
	# cooldown period is over
	#fsm.pop()
	pass


func check_melee_attack(dist_to_player: float, _ppos: Vector2) -> bool:
#
# check_melee_attack
# Check if a melee attack could succeed against a player a ppos.
# dist_to_player - Distance to player
# return - True if player is close enough to be hit by a melee attack.
#
	if !has_melee_attack:
		return false
	# check if I'm close enough to attack
	if dist_to_player < melee_thresh:  # and current_anim == "idle":
		return true
	return false


func start_melee_attack() -> void:
#
# start_melee_attack
# Callback for when the enemy's melee attack has started.
#
	# enable some collision shape with the melee radius on it
	look_at(target)
	$MeleeAttack.visible = true
	$MeleeAttack.monitoring = true
	$Sounds/KnifeSlash.play()


func end_melee_attack():
#
# end_melee_attack
# Callback for when the enemy's melee attack has ended
# 
	# disable the collision shape with the melee radius on it
	$MeleeAttack.visible = false
	$MeleeAttack.monitoring = false
	#fsm.pop()


func take_damage(how_much: int, from: Node) -> void:
#
# take_damage
# Cause this enemy to take a certain amount of damage.
# No effect if is_alive() == false
# how_much - Amount health should be reduced by.
# from - Entity causing the damage.
#
	if health <= 0:
		return
	health -= how_much
	$Sounds/Grunt.play()
	if health < start_health * -0.25:
		emit_signal("died", self, from, true)
		# animation_player.disconnect()
		fsm.replace(BasicEnemyStateLoader.dead(fsm, self))
		$Sounds/Gib.play()
	elif health <= 0:
		# animation_player.disconnect_all()
		emit_signal("died", self, from, false)
		fsm.replace(BasicEnemyStateLoader.dead(fsm, self))
		$Sounds/Gib.play()


func is_alive() -> bool:
# is_alive
# return - True if this enemy is alive
	return health > 0


func on_bitten(worm: Node, bite_damage: int, bite_heal_factor: float) -> void:
#
# on_bitten
# Callback for behaviour when being bitten by worm.
# worm - Pointer to worm
# bite_damage - Amount of damage the bite should do.
# bite_heal_factor - Amount of healing that should be applied if applicable.
#
	take_damage(bite_damage, worm)
	worm.head.increment_blood_level()
	# When biting an enemy, add a segment
	worm.call_deferred("add_segment")
	# ... and heal each segment
	for segment in worm.body:
		segment.take_damage(-start_health * bite_heal_factor, worm)
		yield(get_tree().create_timer(0.1), "timeout")


func get_layer() -> int:
	return $DepthController.get_layer()


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func _on_MeleeAttack_body_entered(body: PhysicsBody2D) -> void:
	if body == self:
		return
	if body.has_method("take_damage"):
		body.take_damage(melee_damage, self)
		$AttackHit.emitting = true


func _on_hide(_new_layer: int) -> void:
	is_hidden = true
	_set_effects_modulate(Color(1, 1, 1, 0))
	$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.1)
	$Tween.start()


func _set_effects_modulate(mod: Color) -> void:
	$MuzzleFlash.modulate = mod
	$Trail.modulate = mod
	$BloodExplode.modulate = mod
	$AttackHit.modulate = mod


func _on_show(_new_layer: int) -> void:
	is_hidden = false
	_set_effects_modulate(Color(1, 1, 1, 1))
	$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.1)
	$Tween.start()


func set_collision_layer(_layer: int) -> void:
	collision_layer = _layer
	$MeleeAttack.collision_layer = _layer


func set_collision_mask(mask: int) -> void:
	collision_mask = mask
	$MeleeAttack.collision_mask = mask


func on_noise_heard(position: Vector2) -> void:
	if not is_alive(): return
	var top = fsm.top()
	if top.has_method("on_noise_heard"):
		top.on_noise_heard(position)
