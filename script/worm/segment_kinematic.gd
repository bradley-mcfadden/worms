#
# Segment controls the movement of a body segment, handles progressive damage,
# a manages taking damage for itself.
#

class_name Segment
extends KinematicBody2D

# Emitted when segment is killed by from. Overkill is true if the segment
# was dealt far mode damage than necessary to kill it.
signal segment_died(segment, from, overkill) # Segment, Node, bool
# Emitted when segment takes any damage.
signal took_damage(segment) # Segment

# Health threshold for when moderate gore sprites should be used
export(float) var moderate_gore_thresh := 0.66
# Health threshold for when heavy gore sprites should be used
export(float) var heavy_gore_thresh := 0.33

# Sprites for gore levels
export(Array) var damage_textures := [
	load("res://img/worm/segment_full.png"),
	load("res://img/worm/segment_gore1.png"),
	load("res://img/worm/segment_gore2.png")
]
# Normal maps for gore levels
export(Array) var damage_normals := [
	load("res://img/worm/segment_full_n.png"),
	load("res://img/worm/segment_gore1_n.png"),
	load("res://img/worm/segment_gore2_n.png"),
]
# Rough radius for a segment approximated by a sphere
export(int) var radius := 45
# Starting health of this segment
export(int) var start_health := 100

enum GoreState {NONE, MODERATE, HEAVY}

# First joint, at the perimeter of sphere facing the head
var j1: Vector2
# Second joint, at the perimeter of sphere facing the tail
var j2: Vector2
# Amount of separation between two segments
var base: float
# Term for sine function when finding oscillation offset
var theta: float
var layer := 0
# Current health
var health: int = start_health
var last_osc_offset := Vector2.ZERO
var current_gore: int = GoreState.NONE

func _ready() -> void:
	health = start_health


func add_camera(cam: Camera2D) -> void:
# add_camera to follow this segment.
# cam - Camera to add as a child of this segment.
	add_child(cam)


func move(vel: Vector2, oscvel: Vector2, _delta: float) -> Vector2:
# move causes the segment to move toward vel, with some apparent oscillation.
# vel - Velocity of the segment.
# oscvel - Vector controlling amount of oscillation in the segment movement.
# return The amount j2 was moved by.
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


func draw() -> void:
	# var shape = $colision
	# if shape is CollisionShape2D:
	# 	var capsule = shape.shape
	# 	draw_arc(Vector2.UP * capsule.height / 4, capsule.radius, -PI, 0, 20, Color.black)
	# 	draw_arc(Vector2.DOWN * capsule.height / 4, capsule.radius, 0, PI, 20, Color.black)
	# else:
	# 	draw_polyline(shape.polygon, Color.black)
	pass


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_layer() -> int:
	return $DepthController.get_layer()


func take_damage(how_much: float, from: Node, emit: bool=true) -> void:
#
# take_damage causes the segment's health to be adjusted by how_much.
# It has no effect if the segment is dead.
#
# how_much - How much to change health by.
# from - Damage causer.
# emit - Whether to notify other nodes that this node took damage or died as a result of this call.
#
	if not is_alive():
		return
	var new_health: float = health - how_much
	health = int(clamp(new_health, 0.0, start_health))
	if new_health > 0:
		if emit: emit_signal("took_damage", self, how_much > 0)
	if new_health < start_health * -0.25:
		if emit: emit_signal("segment_died", self, from, true)
		$BloodExplode.emitting = true
		_die_then_cleanup()
	elif new_health <= 0:
		if emit: emit_signal("segment_died", self, from, false)
		$BloodExplode.emitting = true
		_die_then_cleanup()
	_adjust_gore(float(health) / start_health)


func _die_then_cleanup() -> void:
	$BloodExplode.emitting = true
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.0), 2.0)
	$Tween.start()
	yield(get_tree().create_timer(2.0), "timeout")
	get_parent().free_later_list.append(self)


func _adjust_gore(ratio: float) -> void:
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
# is_alive
# return true if this segment can be considered alie.
	return health > 0


func set_collision_layer(clayer: int) -> void:
	collision_layer = clayer
	

func set_collision_mask(mask: int) -> void:
	collision_mask = mask


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func fade_in(duration: float) -> void:
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0.3), Color(1, 1, 1, 1), duration)
	$Tween.start()
	$DirtExplode.emitting = true


func fade_out(duration: float) -> void:
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.3), duration)
	$Tween.start()
	$DirtExplode.emitting = true


func set_dirt_color(color: Color) -> void:
	var dirt_motion := get_node_or_null("DirtMotion")
	if not dirt_motion == null:
		dirt_motion.color = color
	var dirt_explode := $DirtExplode
	if not dirt_explode == null:
		dirt_explode.color = color
