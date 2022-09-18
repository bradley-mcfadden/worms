class_name Segment
extends KinematicBody2D

signal segment_died(segment, from, overkill)
signal took_damage(segment)

export(float) var moderate_gore_thresh = 0.66
export(float) var heavy_gore_thresh = 0.33

export(Array) var damage_textures := [
	load("res://img/worm/segment_full.png"),
	load("res://img/worm/segment_gore1.png"),
	load("res://img/worm/segment_gore2.png")
]
export(Array) var damage_normals := [
	load("res://img/worm/segment_full_n.png"),
	load("res://img/worm/segment_gore1_n.png"),
	load("res://img/worm/segment_gore2_n.png"),
]
export(int) var radius := 45
export(int) var start_health := 100

enum GoreState {NONE, MODERATE, HEAVY}

# Yes i changed it to Area2D because kinematic isnt nessesery.
var j1
var j2
var base
var theta
var layer := 0
var health: int = start_health
var last_osc_offset := Vector2.ZERO
var current_gore = GoreState.NONE

func _ready():
	health = start_health


func add_camera(cam):
	add_child(cam)


func move(vel: Vector2, oscvel: Vector2, _delta: float) -> Vector2:
	var rot = (j1 - j2).angle()
	var next_pos = j1 + (j2 - j1) / 2

	set_position(next_pos)
	rotation = rot
	var osc_offset = oscvel * int(sin(theta) * vel.length())
	j1 += vel.rotated(rot)
	var delta_j2 = Vector2(vel.x + base - sqrt(base * base - vel.y * vel.y), 0).rotated(rot)
	j2 += delta_j2

	$colision.position = osc_offset  #.rotated(rot)
	$image.position = osc_offset

	last_osc_offset = osc_offset

	return delta_j2


func draw():
	var shape = $colision
	if shape is CollisionShape2D:
		var capsule = shape.shape
		draw_arc(Vector2.UP * capsule.height / 4, capsule.radius, -PI, 0, 20, Color.black)
		draw_arc(Vector2.DOWN * capsule.height / 4, capsule.radius, 0, PI, 20, Color.black)
	else:
		draw_polyline(shape.polygon, Color.black)


func set_layer(new_layer: int):
	$DepthController.set_layer(new_layer)


func get_layer() -> int:
	return $DepthController.get_layer()


func take_damage(how_much, from):
	if not is_alive():
		return
	print("Player is taking " + str(how_much) + " damage")
	if health > 0:
		health -= how_much
		emit_signal("took_damage", self)
	if health < start_health * -0.25:
		emit_signal("segment_died", self, from, true)
		$BloodExplode.emitting = true
	elif health <= 0:
		emit_signal("segment_died", self, from, false)
		$BloodExplode.emitting = true
	_adjust_gore(float(health) / start_health)


func _adjust_gore(ratio: float):
	var new_gore = GoreState.NONE
	if ratio < heavy_gore_thresh:
		new_gore = GoreState.HEAVY
	elif ratio < moderate_gore_thresh:
		new_gore = GoreState.MODERATE
	
	if current_gore != new_gore:
		if damage_textures[new_gore] is String:
			damage_textures[new_gore] = load(damage_textures[new_gore])
		$image.texture = damage_textures[new_gore]
		$image.normal_map = damage_textures[new_gore]
		current_gore = new_gore


func is_alive() -> bool:
	return health > 0


func set_collision_layer(clayer: int):
	# print("segment cl from ", collision_layer, " to ", clayer)
	collision_layer = clayer
	


func set_collision_mask(mask: int):
	# print("segment cm from ", collision_mask, " to ", mask)
	collision_mask = mask


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func fade_in(duration: float):
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0.3), Color(1, 1, 1, 1), duration)
	$Tween.start()
	$DirtExplode.emitting = true
	#$DirtExplode.lifetime = duration


func fade_out(duration: float):
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.3), duration)
	$Tween.start()
	$DirtExplode.emitting = true
	#$DirtExplode.lifetime = duration
