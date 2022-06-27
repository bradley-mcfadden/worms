extends Node2D


export (Vector2) var pos
export (int) var amplitude
export (int) var average
export (float) var speed
export (Color) var color
export (float) var decay

var tdelta
var view_pos
var xpos


func _ready():
	tdelta = 0.0

func _draw():
	var v_rect: Rect2 = get_viewport_transform().affine_inverse().xform(get_viewport_rect())
	var vpos = Vector2()
	vpos.x = clamp(pos.x, v_rect.position.x,  v_rect.position.x + v_rect.size.x)
	vpos.y = clamp(pos.y, v_rect.position.y,  v_rect.position.y + v_rect.size.y)
	view_pos = get_viewport_transform() * get_global_transform() * vpos
	xpos = pos

	color.a *= 1 - decay
	draw_arc(vpos, average + tdelta * amplitude, 0, PI * 2, 30, color)
	# draw_arc(pos, average + (1 + cos(tdelta)) * amplitude, 0, PI*2, 20, Color.red)
	tdelta += speed

	if color.a < 0.1:
		tdelta = 0.0
		color.a = 1.0


func _process(_delta):
	update()
