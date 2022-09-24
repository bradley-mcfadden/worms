tool
extends Area2D

class_name BasicEnemy

signal bullet_created(bullet)
signal died(node, from, overkill)
signal noise_produced(position, audible_radius)

enum SeekState { REACHED_TARGET, NO_TARGET, SEEK_TARGET }

const DRAW_ME = false

var ent_state_prop := {}

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
export(int) var start_health = 100
export(int) var hear_radius = 2000
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
var target = null
var rot = 0
var start_transform
var start_layer
var health = start_health
var is_hidden
var fsm
var animation_player


func _ready():
	set_layer(layer)
	# print("Enemy ", collision_layer)
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
		# print(ray_directions[i], ray_directions[i].rotated(rotation).dot(transform.x))

	start_transform = transform
	start_layer = layer

	fsm = Fsm.new()
	fsm.push(BasicEnemyStateLoader.patrol(fsm, self))

	ent_state_prop[BasicEnemyPatrolState.NAME] = BasicEnemyPatrolState.PROPERTIES
	ent_state_prop[BasicEnemyChaseState.NAME] = BasicEnemyChaseState.PROPERTIES
	ent_state_prop[BasicEnemyDeadState.NAME] = BasicEnemyDeadState.PROPERTIES
	# ent_state_prop[typeof(MeleeAttackState)] = MeleeAttackState.PROPERTIES
	# ent_state_prop[typeof(RangedAttackState)] = RangedAttackState.PROPERTIES

	if has_ranged_attack:
		ent_state_prop[BasicEnemyChaseState.NAME]["threshold"] = ranged_thresh
	else:
		ent_state_prop[BasicEnemyChaseState.NAME]["threshold"] = melee_thresh


func _physics_process(delta: float):
	if Engine.editor_hint:
		return
	var current_estate = fsm.top()
	if current_estate != null:
		current_estate._physics_process(delta)


func move(delta: float):
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


func _draw():
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
	# print(ent_state_prop)
	if !Engine.editor_hint:
		match state:
			BasicEnemyPatrolState.NAME:
				_draw_semicircle(look_distance, f, Color.black)
			BasicEnemyChaseState.NAME:
				_draw_semicircle(look_distance, f, Color.black)
				_draw_semicircle(melee_thresh, f, Color.black)
				_draw_semicircle(ranged_thresh, f, Color.black)
	else:
		_draw_semicircle(look_distance, f, Color.black)
		if has_melee_attack:
			_draw_semicircle(melee_thresh, f, Color.black)
		if has_ranged_attack:
			_draw_semicircle(ranged_thresh, f, Color.black)
		# translate(-global_position)

		_draw_polyline(idle_patrol, Color.black, transform.affine_inverse())
		# translate(global_position)


# draw a semicircle with radius, which travels around the arc for f,
# and is color color
func _draw_semicircle(rradius: float, f: float, color: Color):
	var f2 = f / 2
	var cosf2 = cos(f2)  # cos(x) = -cos(x)
	var sinf2 = sin(f2)  # sin(-x) = -sin(x)
	draw_arc(Vector2.ZERO, rradius, -f2, f2, 20, color)
	draw_line(Vector2(20 * cosf2, 20 * -sinf2), Vector2(rradius * cosf2, rradius * -sinf2), color)
	draw_line(Vector2(20 * cosf2, 20 * sinf2), Vector2(rradius * cosf2, rradius * sinf2), color)


func _draw_polyline(points, color, xform):
	var p2 := []
	for p in points:
		p2.append(xform * p)
	p2.append(p2.front())
	draw_polyline(p2, color)


func _process(_delta):
	update()


func reset():
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


func set_interest():
	# Set interest in each slot based on world direction
	# if owner and owner.has_method("get_path_direction"):
	# var path_direction = owner.get_path_direction(position)
	# if owner and owner.has_method("get_target"):
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


func set_default_interest():
	# Default to moving forward
	for i in num_rays:
		var d = ray_directions[i].rotated(rot).dot(transform.x)
		interest[i] = max(0, d)


func set_danger():
	# Cast rays to find danger directions
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


func choose_direction():
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


func set_target(_target):
	target = _target


# check for the player, and if we find an active player in the field of view,
# acquire it as target and reduce our reaction time
func check_for_player() -> Node:
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


func check_ranged_attack(_dist_to_player, ppos):
	#print("Check ranged attack")
	if !has_ranged_attack:
		return false
	var space_state = get_world_2d().direct_space_state
	var hit: Dictionary = space_state.intersect_ray(global_position, global_position+(ppos-global_position)*fsm.top().PROPERTIES["threshold"], [self], collision_mask)
	if hit.has("collider"):
		# print(hit)
		# and $AnimationPlayer.assigned_animation == "idle"
		if hit["collider"].has_method("take_damage"):
			#$AnimationPlayer.play("ranged_attack")
			print("Doing ranged attack!")
			look_at(hit["position"])
			return true
	return false


func start_ranged_attack():
	# launch a projectile
	var new_bullet = bullet.instance()
	new_bullet.setup(
		self, Vector2.RIGHT.rotated(rotation) * 1000, ranged_damage, 10, collision_layer, layer
	)
	new_bullet.position = $MuzzleFlash.global_position
	new_bullet.rotation = (target - global_position).angle()
	emit_signal("bullet_created", new_bullet)
	$Sounds/GunShot.play()


func end_ranged_attack():
	# cooldown period is over
	#fsm.pop()
	pass


func check_melee_attack(dist_to_player, _ppos):
	if !has_melee_attack:
		return false
	# check if I'm close enough to attack
	#var current_anim = $AnimationPlayer.current_animation
	if dist_to_player < melee_thresh:  # and current_anim == "idle":
		# $AnimationPlayer.play("melee_attack")
		# print("Doing melee attacK!", dist_to_player)
		return true
	return false


func start_melee_attack():
	# enable some collision shape with the melee radius on it
	look_at(target)
	$MeleeAttack.visible = true
	$MeleeAttack.monitoring = true
	$Sounds/KnifeSlash.play()


func end_melee_attack():
	# disable the collision shape with the melee radius on it
	$MeleeAttack.visible = false
	$MeleeAttack.monitoring = false
	#fsm.pop()


func take_damage(how_much, from):
	if health <= 0:
		return
	print("Enemy is taking " + str(how_much) + " damage")
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
	return health > 0


func get_layer() -> int:
	return $DepthController.get_layer()


func set_layer(new_layer: int):
	$DepthController.set_layer(new_layer)


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func _on_MeleeAttack_body_entered(body):
	if body == self:
		return
	if body.has_method("take_damage"):
		body.take_damage(melee_damage, self)
		$AttackHit.emitting = true


func _on_hide():
	is_hidden = true
	_set_effects_modulate(Color(1, 1, 1, 0))
	$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.1)
	$Tween.start()


func _set_effects_modulate(mod: Color):
	$MuzzleFlash.modulate = mod
	$Trail.modulate = mod
	$BloodExplode.modulate = mod
	$AttackHit.modulate = mod


func _on_show():
	is_hidden = false
	_set_effects_modulate(Color(1, 1, 1, 1))
	$Tween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.1)
	$Tween.start()


func set_collision_layer(_layer: int):
	collision_layer = _layer
	$MeleeAttack.collision_layer = _layer


func set_collision_mask(mask: int):
	collision_mask = mask
	$MeleeAttack.collision_mask = mask


func on_noise_heard(position: Vector2):
	if not is_alive(): return
	print(self, " heard a noise at ", position)
