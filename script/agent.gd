extends Node2D

export(int) var num_rays = 4
export(int) var look_ahead = 400
export(float) var max_angle = PI / 4
export(Array) var walk_points = []
export(PackedScene) var target_follow

var velocity := Vector2.ZERO
var target = null
var follower


func _ready():
	var tf = target_follow.instance()
	tf.parent = self
	add_child(tf)


func _draw():
	draw_arc(Vector2.ZERO, 20, 0, PI * 2, 20, Color.aqua)
	draw_line(Vector2.ZERO, Vector2(20, 0), Color.aqua)


func _process(_delta):
	update()


func _input(event):
	if event.is_action_pressed("mouse_lmb"):
		set_target(get_global_mouse_position())


func get_target() -> Vector2:
	return target


func set_target(target: Vector2):
	self.target = target
