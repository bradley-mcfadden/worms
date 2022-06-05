extends Position2D

const MAX_SPEED = 400
const ACC = 20

# fill this with camera2D node 
export (PackedScene) var camera
export (PackedScene) var Segment
export (PackedScene) var Head
export (PackedScene) var Tail
export (int) var segment_number = 30
# difference between two segments' theta along sin curve
# controls oscillation
export (float) var tdelta = 0.75
export (int) var max_speed = MAX_SPEED
export (int) var acceleration = ACC
export (float) var speed_decay = 0.95


var body = []
var rot = 0
var heading = 0
# If initial velocity is not nonzero, then the worm collapses to a single point
var vel = Vector2(0.001, 0)
# base is default distance betveen joints. 
var base = 40
var j1 = Vector2()
var counter = 0
var head
var tail
var wide_camera


func _ready():
# This loop will set segment's properties.
# Every segment can have different base, scale...
	for i in range(segment_number):
		var segment
		if i == 0:
			segment = Head.instance()
			head = segment
		elif i == segment_number - 1:
			segment = Tail.instance()
			tail = segment
		else:
			segment = Segment.instance()
		add_child(segment)
		segment.base = base
		segment.j1 = j1 
		j1 = Vector2(j1.x - base, 0)
		segment.j2 = j1
		print("j1: " + str(segment.j1) + " j2: " + str(segment.j2))
		body.append(segment)
#	this reverses the order of segments in the tree 
	for i in body:
		move_child(i, 0)
	if camera:
		wide_camera = camera.instance()
		scale_camera()
		add_child(wide_camera)
	
	for ability in $AbilitiesContainer.get_children():
		ability.parent = self


func _draw():
	for segment in body:
		draw_line(segment.j1, segment.j2, Color.red)


func _process(_delta):
	update()
	update_camera_position()


func update_camera_position():
	var sum := Vector2.ZERO
	for segment in body:
		sum += segment.position
		
	var avg = sum / len(body)
	wide_camera.position = avg


# Do not touch this function.
func _physics_process(delta):
	_control(delta)
	if vel.length() > 0 :
		var vel_ = vel.rotated(heading) * delta
		var ivel = Vector2(vel.y, vel.x).normalized()

		var i = counter
		for segment in body :
			vel_ = Vector2(vel_.length(), 0).rotated(
					(segment.j1 - segment.j2).angle_to(vel_))
			segment.theta = i
			var j2 = segment.move(vel_, ivel, delta)
			vel_ = j2
			i += tdelta

		counter += 0.2


func _control(delta):
#	This is just example just make sure you dont allow beckvard movement.
	if Input.is_action_pressed("ui_up"):
		vel.x += acceleration
		vel.x = vel.x if vel.x <= max_speed else vel.x * speed_decay
	else:
		vel *= speed_decay
	if Input.is_action_pressed("ui_left"):
		heading -= PI * delta * 3
	elif Input.is_action_pressed("ui_right"):
		heading += PI * delta * 3
	if Input.is_action_just_pressed("add_segment"):
		add_segment()
		# split()
	if Input.is_action_just_pressed("scale_up"):
		scale_segments(1.1)
	for i in range(0, 4):
		if Input.is_action_pressed("ability" + str(i + 1)):
			$AbilitiesContainer.get_child(i).invoke()


func add_segment():
	var last2 = body[body.size() - 2]
	var new_seg = Segment.instance()
	new_seg.base = base
	new_seg.j1 = last2.j2
	new_seg.j2 = new_seg.j1 + last2.j2 - last2.j1
	body.pop_back().free()
	body.append(new_seg)
	add_child(new_seg)
	move_child(new_seg, 0)

	var last = body.back()
	var new_tail = Tail.instance()
	new_tail.base = base
	new_tail.j1 = last.j2
	new_tail.j2 = new_tail.j1 + last.j2 - last.j1
	body.append(new_tail)
	add_child(new_tail)
	move_child(new_tail, 0)
	
	scale_camera()


func scale_segments(factor):
	var j2 = null
	for segment in body:
		segment.base *= factor
		if segment.has_method("scale_children"):
			segment.scale_children(factor)
		else:
			segment.scale *= factor
		
		if j2 == null:
			j1 = segment.j1
		else:
			segment.j1 = j2
		segment.j2 = segment.j1 + (segment.j2 - segment.j1) * factor
		j2 = segment.j2


func split():
	var destroyed_parts = []
	for _i in range(5):
		destroyed_parts.append(body.pop_back())
		
	return destroyed_parts


func apply_boost_speed():
	max_speed *= 2
	acceleration *= 2
	$BoostTimer.start()


func reset_boost_speed():
	max_speed *= 0.5
	acceleration *= 0.5


func scale_camera():
	if camera:
		wide_camera.zoom = Vector2(0.1, 0.1) * len(body)
