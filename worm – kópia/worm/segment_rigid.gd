extends RigidBody2D

class_name SegmentRigid

# Yes i changed it to Area2D because kinematic isnt nessesery.
var j1
var j2
var base
var theta

var move_target = null
var rotate_target = null

var wait_rot

func add_camera(cam):
	add_child(cam)

func move(vel, oscvel):
	var rot = (j1 - j2).angle()
	wait_rot = rot
	#position = j1 + (j2 - j1) / 2
	move_to(j1 + (j2 - j1) * 0.5)
	#rotation = rot
	rotate_to(rot)
	
	var osc_offset = oscvel * int(sin(theta) * vel.length())
	j1 += vel.rotated(rot)
	j2 += Vector2(vel.x + base - sqrt(base * base - vel.y * vel.y), 0).rotated(rot)
	
	$colision.position = osc_offset#.rotated(rot)
	$image.position = osc_offset

func move_to(pos):
	move_target = pos

func rotate_to(th):
	rotate_target = th

func _integrate_forces(state):
	var xform:Transform2D = state.get_transform()
	if move_target != null:
		xform.origin = move_target
		set_position(move_target)
		move_target = null
	if rotate_target != null:
		# var orig:Vector2 = xform.get_origin()
		# xform.translated(-orig).rotated(-xform.get_rotation()).rotated(rotate_target).translated(orig)
		#xform.rotation = rotate_target
		set_rotation(rotate_target)
		rotate_target = null
	state.set_transform(xform)

