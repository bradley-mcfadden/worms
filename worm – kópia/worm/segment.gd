extends Area2D
# Yes i changed it to Area2D because kinematic isnt needed.
var j1
var j2
var base
func add_camera(cam):
	add_child(cam)
func move(vel):
	var rot=(j1-j2).angle()
	
	position=j1+(j2-j1)/2
	rotation=rot
	j1+=vel.rotated(rot)
	j2+=Vector2(vel.x+base-sqrt(base*base-vel.y*vel.y),0).rotated(rot)

	
	
	