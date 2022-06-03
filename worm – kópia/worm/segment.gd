extends Area2D


# Yes i changed it to Area2D because kinematic isnt nessesery.
var j1
var j2
var base
var theta

func add_camera(cam):
	add_child(cam)

func move(vel, oscvel):
	var rot = (j1 - j2).angle()
	
	position = j1 + (j2 - j1) / 2
	rotation = rot
	
	var osc_offset = oscvel * int(sin(theta) * vel.length())
	j1 += vel.rotated(rot)
	j2 += Vector2(vel.x + base - sqrt(base * base - vel.y * vel.y), 0).rotated(rot)
	
	$colision.position = osc_offset#.rotated(rot)
	$image.position = osc_offset
