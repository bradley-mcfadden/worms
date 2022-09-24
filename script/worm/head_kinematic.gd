extends "res://script/worm/segment_kinematic.gd"

signal changed_animation(from, to)

const IDLE = "idle"
const MOUTH_CHOMP = "mouth_chomp"
const MOUTH_OPEN_WIDE = "mouth_open_wide"
const CHOMP_TO_IDLE = "chomp_to_idle"

export(int) var bite_damage := 100
export(int) var max_blood_level := 4
export(float) var bite_heal_factor := 0.5

var anim_player: AnimationPlayer
var curr_blood_level := 0

func _ready():
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
	var rot = (j1 - j2).angle()
	var next_pos = j1 + (j2 - j1) / 2

	# var linv := move_and_slide(next_pos-position, Vector2.ZERO, false, 4, PI*2, true) * delta
	var collider := move_and_collide(next_pos - position, true)
	if collider != null:
		vel.x = 0
	rotation = rot
	var osc_offset = oscvel * int(sin(theta) * vel.length())
	j1 += vel.rotated(rot)
	var delta_j2 = Vector2(vel.x + base - sqrt(base * base - vel.y * vel.y), 0).rotated(rot)
	j2 += delta_j2

#	Vector2(
#					segment.base + vel_.x - sqrt(
#						segment.base * segment.base - vel_.y * vel_.y), 0
#						).rotated(segment.rotation)

	$colision.position = osc_offset  #.rotated(rot)
	$image.position = osc_offset
	$blood.position = osc_offset

	# return collider != null
	return delta_j2


func set_layer(new_layer: int):
	$DepthController.set_layer(new_layer)


func set_collision_layer(layer: int):
	collision_layer = layer
	$BiteHitbox.collision_layer = layer


func set_collision_mask(mask: int):
	collision_mask = mask
	$BiteHitbox.collision_mask = mask


func get_animation_player() -> Node:
	return anim_player


func toggle_bite_hitbox(is_on):
	$BiteHitbox.monitorable = is_on
	$BiteHitbox.monitoring = is_on


func _on_BiteHitbox_area_entered(area):
	if area.has_method("take_damage"):
		if not area.is_alive(): return
		area.take_damage(bite_damage, self)
		increment_blood_level()
		$BiteHit.play()
		var parent: Node = get_parent()
		# When biting an enemy, add a segment
		parent.call_deferred("add_segment")
		# ... and heal each segment
		for segment in parent.body:
			segment.take_damage(-start_health * bite_heal_factor, parent)
			yield(get_tree().create_timer(0.1), "timeout")


func increment_blood_level():
	var step = 1.0 / max_blood_level
	curr_blood_level = curr_blood_level + 1 if curr_blood_level < max_blood_level else curr_blood_level
	$blood.modulate = Color(1.0, 1.0, 1.0, curr_blood_level * step)
