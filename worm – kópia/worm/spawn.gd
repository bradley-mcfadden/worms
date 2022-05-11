extends Position2D
var body=[]
var rot=0
var heading=0
var vel=Vector2()
#base is deafult distance betveen joints. 
var base=60
var j1=Vector2()
var counter = 0

# fill this with camera2D node 
export (PackedScene) var camera
export (PackedScene) var Segment
export (int) var segment_number
export (int) var offset
export (float) var tdelta 

func _ready():
#this loop will set segments properties.Ewiy segment can have diferent base,scale...
	for i in range(segment_number):
		var segment=Segment.instance()
		add_child(segment)
		segment.base=base
		segment.j1=j1 
		j1=Vector2(j1.x-base, 0)
		segment.j2=j1
		body.append(segment)
#	this revers order of segments in three 
	for i in body:
		move_child(i,0)
	if camera:
#		you can also manipulate with segments this wey
		body[0].add_camera(camera.instance())

func _draw():
	for segment in body:
		draw_line(segment.j1, segment.j2, Color.red)

func _process(delta):
	update()

#Do not touch this function.
func _physics_process(delta):
	control(delta)
	if vel.length()>0:
		var vel_=vel.rotated(heading)*delta
		var ivel = Vector2(vel.y, vel.x).normalized()
		
		var i = counter
		for segment in body :
			vel_=Vector2(vel_.length(),0).rotated((segment.j1-segment.j2).angle_to(vel_))
			segment.theta = i
			segment.move(vel_, ivel, tdelta)
			vel_=Vector2(segment.base+vel_.x-sqrt(segment.base*segment.base-vel_.y*vel_.y),0).rotated(segment.rotation)
			i += tdelta
			
		counter += 0.2

func control(delta):
#	This is just example just make sure you dont alaut beckvard movement.
	vel = Vector2(400, 0)
	if Input.is_action_pressed("ui_left"):
		heading-=PI*delta*3
	elif Input.is_action_pressed("ui_right"):
		heading+=PI*delta*3
	elif Input.is_action_just_pressed("add_segment"):
		add_segment()
		# split()
	elif Input.is_action_just_pressed("scale_up"):
		scale(1.1)

func add_segment():
	var last = body.back()
	var segment = Segment.instance()
	segment.base = base
	segment.j1 = last.j2
	segment.j2 = segment.j1 + last.j2 - last.j1
	body.append(segment)
	add_child(segment)
	move_child(segment, 0)

func scale(factor):
	var j2 = null
	for segment in body:
		segment.base *= factor
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
