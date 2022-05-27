extends RigidBody2D

class_name SegmentRigid

# Yes i changed it to Area2D because kinematic isnt nessesery.
var j1
var j2
var base
var theta

var move_target = null
var rotate_target = null

var wait_rot = null
var wait_pos = null

func add_camera(cam):
	add_child(cam)

func move(vel, oscvel):
	var rot = (j1 - j2).angle()
	wait_rot = rot
	#position = j1 + (j2 - j1) / 2
	# move_to(j1 + (j2 - j1) * 0.5)
	var pos = j1 + (j2 - j1) / 2
	wait_pos = pos
	set_position(pos)
	#rotation = rot
	# rotate_to(rot)
	set_rotation(rot)
	
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
#	var xform:Transform2D = state.get_transform()
#	if move_target != null:
#		# xform.origin = move_target
#		set_position(move_target)
#		# state.set_linear_velocity(move_target)
#		move_target = null
#	if rotate_target != null:
#		# var orig:Vector2 = xform.get_origin()
#		# xform.translated(-orig).rotated(-xform.get_rotation()).rotated(rotate_target).translated(orig)
#		#xform.rotation = rotate_target
#		set_rotation(rotate_target)
#		rotate_target = null
#	state.set_transform(xform)
	# var xform:Transform2D = state.get_transform()
	# var xrot = atan2(xform.x.y, xform.x.x)
	# var xrotd = 
	# var yrot = atan2(xform.y.y, xform.y.x)
	if wait_pos != null:
		set_position(wait_pos)
	if wait_rot != null:
		set_rotation(wait_rot)

func scale_children(factor):
	for child in get_children():
		child.scale *= factor
