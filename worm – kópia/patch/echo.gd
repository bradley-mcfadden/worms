extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Vector2) var pos
export (int) var amplitude
export (int) var average
export (float) var speed
export (Color) var color
export (float) var decay
var tdelta
var view_pos
var xpos

# Called when the node enters the scene tree for the first time.
func _ready():
	tdelta = 0.0

func _draw():
	var view := get_viewport_rect()
	var vt := get_viewport_transform()
	var vpos = Vector2()
	vpos.x = clamp(pos.x, -vt.origin.x,  -vt.origin.x + view.size.x)
	vpos.y = clamp(pos.y, -vt.origin.y, -vt.origin.y + view.size.y)
	view_pos = vpos
	xpos = pos
	#print(vpos, vt.origin)

	color.a *= 1 - decay
	draw_arc(vpos, average + tdelta * amplitude, 0, PI*2, 30, color)
	# draw_arc(pos, average + (1 + cos(tdelta)) * amplitude, 0, PI*2, 20, Color.red)
	tdelta += speed
	
	if color.a < 0.1:
		tdelta = 0.0
		color.a = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _input(event):
	if Input.is_action_just_pressed("add_segment"):
		var vt := get_viewport_transform()
		print(-vt.origin)
		print(xpos)
		print(view_pos)
