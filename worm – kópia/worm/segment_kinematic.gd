extends KinematicBody2D

# Yes i changed it to Area2D because kinematic isnt nessesery.
var j1
var j2
var base
var theta

func add_camera(cam):
	add_child(cam)

func move(vel:Vector2, oscvel:Vector2, delta:float) -> Vector2:
	var rot = (j1 - j2).angle()
	var next_pos = j1 + (j2 - j1) / 2
	
	set_position(next_pos)
	rotation = rot
	var osc_offset = oscvel * int(sin(theta) * vel.length())
	j1 += vel.rotated(rot)
	var delta_j2 = Vector2(vel.x + base - sqrt(base * base - vel.y * vel.y), 0).rotated(rot)
	j2 += delta_j2
	
	$colision.position = osc_offset#.rotated(rot)
	$image.position = osc_offset
	
	return delta_j2
