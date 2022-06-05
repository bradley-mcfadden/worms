extends "res://worm/segment_kinematic.gd"


var anim_player:AnimationPlayer

const IDLE = "idle"
const MOUTH_CHOMP = "mouth_chomp"
const MOUTH_OPEN_WIDE = "mouth_open_wide"
const CHOMP_TO_IDLE = "chomp_to_idle"


func _ready():
	anim_player = $AnimationPlayer
	anim_player.play(IDLE)


func move(vel:Vector2, oscvel:Vector2, delta:float) -> Vector2:
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
