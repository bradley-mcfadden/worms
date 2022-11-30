# head_kinematic.gd controls the movement and actions of the worm head.
#
# It moves the same as other segments, but also has an animation player to
# worry about, and some blood splatter effects that do not appear on other
# segments.

extends "res://script/worm/segment_kinematic.gd"

# Emitted when "something" is bitten
signal interactible_bitten

const IDLE := "idle"
const MOUTH_CHOMP := "mouth_chomp"
const MOUTH_OPEN_WIDE := "mouth_open_wide"
const CHOMP_TO_IDLE := "chomp_to_idle"

export(int) var max_blood_level := 4

onready var layer_checker: Area2D = $LayerCheck
var anim_player: AnimationPlayer
var curr_blood_level := 0

func _ready() -> void:
	anim_player = $AnimationPlayer
	anim_player.play(IDLE)

	damage_textures = [
		load("res://img/worm/ss_full.png"),
		load("res://img/worm/ss_gore1_full.png"),
		load("res://img/worm/ss_gore2_full.png"),
	]

	damage_normals = [
		"res://img/worm/ss_full_n.png",
		"res://img/worm/ss_gore1_full_n.png",
		"res://img/worm/ss_gore2_full_n.png",
	]


func move(vel: Vector2, oscvel: Vector2, _delta: float) -> Vector2:
#
# move causes this segment to move.
#
# vel - Linear velocity
# oscvel - Scale vector for amount to move horizontallty and linearly
# return - Offset of second joint from last move call.
	var rot = (j1 - j2).angle()
	var next_pos = j1 + (j2 - j1) / 2

	var collider := move_and_collide(next_pos - position, true)
	if collider != null:
		vel = (global_position - collider.position).normalized().rotated(-rot) * vel.length()
	rotation = rot
	var osc_offset = oscvel * int(sin(theta) * vel.length())
	j1 += vel.rotated(rot)
	var delta_j2 = Vector2(vel.x + base - sqrt(base * base - vel.y * vel.y), 0).rotated(rot)
	j2 += delta_j2

	$colision.position = osc_offset
	$image.position = osc_offset
	$blood.position = osc_offset

	return delta_j2


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func set_collision_layer(layer: int) -> void:
	collision_layer = layer
	$BiteHitbox.collision_layer = layer


func set_collision_mask(mask: int) -> void:
	collision_mask = mask
	$BiteHitbox.collision_mask = mask
	var start_mask: int = $DepthController.start_mask
	$LayerCheck.collision_mask = 0
	if layer > 0:
		$LayerCheck.collision_mask |= start_mask << (2 * (layer - 1))
	$LayerCheck.collision_mask |= start_mask << (2 * (layer + 1))


func get_animation_player() -> Node:
	return anim_player


func toggle_bite_hitbox(is_on: bool) -> void:
#
# toggle_bite_hitbox changes the state of the bite hitbox.
# is_on - True if the hitbox should collide with other hitboxes.
#
	$BiteHitbox.monitorable = is_on
	$BiteHitbox.monitoring = is_on


func _on_BiteHitbox_area_entered(area: Area2D) -> void:
	var worm := get_parent()
	for ability in worm.active_abilities():
		if ability.has_method("on_area_entered_mouth"):
			ability.on_area_entered_mouth(worm, area)


func _on_BiteHitbox_body_entered(body: Node) -> void:
	var worm := get_parent()
	for ability in worm.active_abilities():
		if ability.has_method("on_body_entered_mouth"):
			ability.on_body_entered_mouth(worm, body)


func find_overlapping_in_mouth() -> void:
#
# find_overlapping_in_mouth
# Check for areas and bodies in the bite hitbox, and call appropriate method
# on them.
# 
	for area in $BiteHitbox.get_overlapping_areas():
		_on_BiteHitbox_area_entered(area)
	for body in $BiteHitbox.get_overlapping_bodies():
		_on_BiteHitbox_body_entered(body)


func increment_blood_level() -> void:
# 
# increment_blood_level causes the sprite to change to the next bloodstain level.
#
	var step = 1.0 / max_blood_level
	curr_blood_level = curr_blood_level + 1 if curr_blood_level < max_blood_level else curr_blood_level
	$blood.modulate = Color(1.0, 1.0, 1.0, curr_blood_level * step)


func overlaps_above() -> bool:
#
# overlaps_above
# Does the depth layer above overlap at all with this head?
# return - True if layer above overlaps, false otherwise.
#
	for body in layer_checker.get_overlapping_bodies():
		if body.has_method("get_layer"):
			if body.get_layer() == layer - 1:
				return true
	return false


func overlaps_below() -> bool:
#
# overlaps_below
# Does the depth layer below overlap at all with this head?
# return - True if layer below overlaps, false otherwise.
#
	for body in layer_checker.get_overlapping_bodies():
		if body.has_method("get_layer"):
			if body.get_layer() == layer + 1:
				return true
	return false
