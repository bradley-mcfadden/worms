tool
extends Node2D

signal bullet_created(bullet)
signal died(node, from, overkill)

enum SeekState {REACHED_TARGET, NO_TARGET, SEEK_TARGET}
enum EntityState { PATROL, CHASE, DEAD }

const DRAW_ME = true

export (Dictionary) var ent_state_prop = {
	EntityState.PATROL : {
		color = Color.aquamarine, speed = 250, threshold = 32, fov = 90},
	EntityState.CHASE : {
		color = Color.crimson, speed = 350, threshold = 200, fov = 360},
	EntityState.DEAD : {
		color = Color.black, speed = 0, threshold = 0, fov = 0},
}

export (float) var steer_force := 0.5
export (int) var look_ahead := 125
export (int) var num_rays := 12
export (PoolVector2Array) var idle_patrol := PoolVector2Array()
export (float) var fov := 90.0
export (int) var look_distance := 300
export (int) var reaction_time = 12
export (bool) var has_ranged_attack := true
export (bool) var has_melee_attack := false
export (int) var ranged_damage := 20
export (int) var melee_damage := 50
export (PackedScene) var bullet
export (int) var start_health = 100
export var melee_thresh := 50
export var ranged_thresh := 200
export var layer := 0

# context array
var ray_directions := []
var interest := []
var danger := []
var chosen_dir := Vector2.ZERO
var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO
var collision_layer := 2147483647
var patrol_idx := 0
var current_state = EntityState.PATROL
var target = null
var rot = 0
var start_transform
var start_layer 
var health = start_health
var is_hidden


func _ready():
	set_layer(layer)
	print("Enemy ", collision_layer)
	if Engine.editor_hint: return
	if has_ranged_attack:
		ent_state_prop[EntityState.CHASE]["threshold"] = ranged_thresh
	else:
		ent_state_prop[EntityState.CHASE]["threshold"] = melee_thresh
	
	$AnimationPlayer.play("idle")
	num_rays += 1
	fov = deg2rad(fov)
	
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	var angle_step = 3 * PI / 2 / (num_rays - 1)
	for i in num_rays:
		var angle = i * angle_step - 3 * PI/4
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		if angle > PI / 2 or angle < 3 * PI / 2:
			ray_directions[i] *= 0.5
		print(ray_directions[i], ray_directions[i].rotated(rotation).dot(transform.x))
		
	start_transform = transform
	start_layer = layer


func _physics_process(delta:float):
	if Engine.editor_hint: return
	var state = set_interest()
	
	match state:
		SeekState.REACHED_TARGET:
			pass
		_:
			set_danger()
			choose_direction()
			var speed = ent_state_prop[current_state]["speed"]
			var desired_velocity = chosen_dir.rotated(rot) * speed
			velocity = velocity.linear_interpolate(desired_velocity, steer_force)
			rotation = velocity.angle()
			position += velocity * delta
	match current_state:
		EntityState.CHASE:
			var dist_to_player = global_position.distance_to(target)
			var did_attack = check_melee_attack(dist_to_player)
			if did_attack: return
			did_attack = check_ranged_attack(dist_to_player)
		EntityState.PATROL:
			pass
		EntityState.DEAD:
			pass
	if is_hidden and !current_state == EntityState.DEAD:
		$echo.set_visible(true)
	else:
		$echo.set_visible(false)


func _draw():
	if not DRAW_ME: return
	var color = ent_state_prop[current_state]["color"]
	draw_arc(Vector2.ZERO, 20, 0, PI * 2, 20, color)
	draw_line(Vector2.ZERO, Vector2(20, 0), color)
	var f = deg2rad(ent_state_prop[current_state]["fov"])
	
	if !Engine.editor_hint:
		match current_state:
			EntityState.PATROL:
				_draw_semicircle(look_distance, f, Color.black)
			EntityState.CHASE:
				_draw_semicircle(melee_thresh, f, Color.black)
				_draw_semicircle(ranged_thresh, f, Color.black)
	else:
		_draw_semicircle(look_distance, f, Color.black)
		_draw_semicircle(melee_thresh, f, Color.black)
		_draw_semicircle(ranged_thresh, f, Color.black)
		# translate(-global_position)
		
		_draw_polyline(idle_patrol, Color.black, transform.affine_inverse())
		# translate(global_position)


# draw a semicircle with radius, which travels around the arc for f,
# and is color color
func _draw_semicircle(radius:float, f:float, color:Color):
	var f2 = f / 2
	var cosf2 = cos(f2) # cos(x) = -cos(x)
	var sinf2 = sin(f2) # sin(-x) = -sin(x)
	draw_arc(Vector2.ZERO, radius, -f2, f2, 20, color)
	draw_line(Vector2(20 * cosf2, 20 * -sinf2),
		Vector2(radius * cosf2, radius * -sinf2), color)
	draw_line(Vector2(20 * cosf2, 20 * sinf2),
		Vector2(radius * cosf2, radius * sinf2), color)


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
	collision_layer = 2147483647
	patrol_idx = 0
	current_state = EntityState.PATROL
	target = null
	rot = 0
	transform = start_transform
	health = start_health
	layer = start_layer


func set_interest():
	# Set interest in each slot based on world direction
	# if owner and owner.has_method("get_path_direction"):
		# var path_direction = owner.get_path_direction(position)
	# if owner and owner.has_method("get_target"):
	var path_target = get_target()
	if path_target == null: 
		set_default_interest()
		return SeekState.NO_TARGET
	var threshold = ent_state_prop[current_state]["threshold"]
	if position.distance_to(path_target) < threshold:
		return SeekState.REACHED_TARGET
	var path_direction = (path_target - position)
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
		var result := space_state.intersect_ray(position,
				position + ray_directions[i].rotated(rot) * look_ahead,
				[self], collision_layer)
		if result:
			danger[i] = 1.0 #- result.position.distance_to(position) / look_ahead
		else:
			danger[i] = 0.0


func set_parent(parent):
	self.parent = parent


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


func get_target():
	if current_state != EntityState.DEAD:
		check_for_player()
	match current_state:
		EntityState.PATROL:
			return get_patrol_target()
		EntityState.CHASE:
			return target
		EntityState.DEAD:
			return position
		_:
			return null


# set target to closest point in patrol
func get_patrol_target():
	var n = len(idle_patrol)
	if n == 0: return null
	var threshold = ent_state_prop[current_state]["threshold"]
	if position.distance_to(idle_patrol[patrol_idx]) < threshold:
		patrol_idx = patrol_idx + 1 if patrol_idx  < n - 1 else 0
	return idle_patrol[patrol_idx]

func get_next_patrol_target():
	var n = len(idle_patrol)
	patrol_idx = patrol_idx + 1 if patrol_idx  < n - 1 else 0


# check for the player, and if we find an active player in the field of view,
# acquire it as target and reduce our reaction time
func check_for_player():
	if not get_parent().has_method("get_players"): return
	var players = get_parent().get_players()
	
	# Prefer finding a player
	var space_state = get_world_2d().direct_space_state
	for player in players:
		var entities:Array = player.get_entity_positions()
		for ent in entities:
			var angle_to_player = (ent.position - position).rotated(-rotation).angle()
			var dist_to_player = position.distance_to(ent.position)
			var f = deg2rad(ent_state_prop[current_state]["fov"])
			if (
			#	collide.has('collider') 
			#	and collide['collider'] == player #and player.is_alive() 
			#and 
			angle_to_player < f * 0.5 
			and ent.get_layer() == get_layer()
			and dist_to_player < look_distance
			and ent.is_alive()):
				## Add reaction time here probably ##
				if reaction_time > 0:
					reaction_time -= 1
				else:
					current_state = EntityState.CHASE
					target = ent.position
			else:
				target = global_position
				current_state = EntityState.PATROL


func check_ranged_attack(dist_to_player):
	#print("Check ranged attack")
	if !has_ranged_attack: return false
	var space_state = get_world_2d().direct_space_state
	var hit:Dictionary = space_state.intersect_ray(
		global_position, target, [self], collision_layer)
	# print(hit)
	if (dist_to_player < ranged_thresh 
	and $AnimationPlayer.assigned_animation == "idle"
	and hit.has("collider") and hit["collider"].has_method("take_damage")):
		$AnimationPlayer.play("ranged_attack")
		print("Doing ranged attack!")
		return true
	return false


func start_ranged_attack():
	# launch a projectile
	look_at(target)
	var new_bullet = bullet.instance()
	new_bullet.setup(self, (target - global_position).normalized() * 1000, 
		ranged_damage, 10, collision_layer, layer)
	new_bullet.position = global_position
	new_bullet.rotation = (target - global_position).angle()
	emit_signal("bullet_created", new_bullet)


func end_ranged_attack():
	# cooldown period is over
	$AnimationPlayer.play("idle")


func check_melee_attack(dist_to_player):
	if !has_melee_attack: return false
	# check if I'm close enough to attack
	var current_anim = $AnimationPlayer.current_animation
	if dist_to_player < melee_thresh and current_anim == "idle": 
		$AnimationPlayer.play("melee_attack")
		print("Doing melee attacK!", dist_to_player)
		return true
	#else:
	#	print($AnimationPlayer.assigned_animation)
	return false


func start_melee_attack():
	# enable some collision shape with the melee radius on it
	look_at(target)
	$MeleeAttack.visible = true
	$MeleeAttack.monitoring = true


func end_melee_attack():
	# disable the collision shape with the melee radius on it
	$MeleeAttack.visible = false
	$MeleeAttack.monitoring = false
	$AnimationPlayer.play("idle")


func take_damage(how_much, from):
	print("Enemy is taking " + str(how_much) + " damage")
	if health > 0: health -= how_much
	if health < start_health * -0.25:
		emit_signal("died", self, from, true)
		current_state = EntityState.DEAD
	elif health <= 0:
		emit_signal("died", self, from, false)
		current_state = EntityState.DEAD


func is_alive() -> bool:
	return health > 0


func get_layer() -> int:
	return $DepthController.get_layer()


func set_layer(new_layer:int):
	$DepthController.set_layer(new_layer)


func get_depth_controllers() -> Array:
	return [$DepthController,]


func _on_MeleeAttack_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(melee_damage, self)


func _on_Timer_timeout():
	if is_alive():
		take_damage(10, null)


func _on_hide():
	is_hidden = true
	$Tween.interpolate_property(self, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.1)
	$Tween.start()


func _on_show():
	is_hidden = false
	$Tween.interpolate_property(self, "self_modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.1)
	$Tween.start()
