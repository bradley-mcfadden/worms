extends "res://worm/segment_kinematic.gd"

signal changed_animation(from, to)

const IDLE = "idle"
const MOUTH_CHOMP = "mouth_chomp"
const MOUTH_OPEN_WIDE = "mouth_open_wide"
const CHOMP_TO_IDLE = "chomp_to_idle"

export (int) var bite_damage := 100

var anim_player:AnimationPlayer


func _ready():
	anim_player = $AnimationPlayer
	_change_animation("idle")


func move(vel:Vector2, oscvel:Vector2, _delta:float) -> Vector2:
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
	
	$colision.position = osc_offset#.rotated(rot)
	$image.position = osc_offset
	
	# return collider != null
	return delta_j2


func set_layer(new_layer:int):
	$DepthController.set_layer(new_layer)


func set_collision_layer(layer:int):
	collision_layer = layer
	$BiteHitbox.collision_layer = layer


func set_collision_mask(mask:int):
	collision_mask = mask
	$BiteHitbox.collision_mask = mask

func get_animation_player() -> Node:
	return anim_player


func _on_mouth_open_wide_end():
	_change_animation("mouth_chomp")
	toggle_bite_hitbox(true)


func _on_mouth_chomp_end():
	_change_animation("chomp_to_idle")
	toggle_bite_hitbox(false)


func _on_chomp_to_idle_end():
	_change_animation("idle")
	


func _change_animation(to:String):
	emit_signal("changed_animation", anim_player.current_animation, to) 


func toggle_bite_hitbox(is_on):
	$BiteHitbox.monitorable = is_on
	$BiteHitbox.monitoring = is_on


func _on_BiteHitbox_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(bite_damage, self)
