extends Position2D
var body=[]
var rot=0
var heading=0
var vel=Vector2()
#base is deafult distance betveen joints. 
var base=40
var j1=Vector2()

# fill this with camera2D node 
export (PackedScene) var camera
export (PackedScene) var Segment
export (int) var segment_number
func _ready():
#this loop will set segments properties.Ewiy segment can have diferent base,scale...
	for i in range(segment_number):
		var segment=Segment.instance()
		add_child(segment)
		segment.base=base
		segment.j1=j1
		j1=Vector2(j1.x-base,0)
		segment.j2=j1
		body.append(segment)
#	this revers order of segments in three 
	for i in body:
		move_child(i,0)
	if camera:
#		you can also manipulate with segments this wey
		body[0].add_camera(camera.instance())
#Do not touch this function.
func _physics_process(delta):
	control(delta)
	if vel.length()>0:
		var vel_=vel.rotated(heading)*delta
		for segment in body :
			vel_=Vector2(vel_.length(),0).rotated((segment.j1-segment.j2).angle_to(vel_))
			segment.move(vel_)
			vel_=Vector2(segment.base+vel_.x-sqrt(segment.base*segment.base-vel_.y*vel_.y),0).rotated(segment.rotation)

func control(delta):
#	This is just example just make sure you dont alaut beckvard movement.
	vel=Vector2(1000,0)
	if Input.is_action_pressed("ui_left"):
		heading-=PI*delta*3
	elif Input.is_action_pressed("ui_right"):
		heading+=PI*delta*3
	