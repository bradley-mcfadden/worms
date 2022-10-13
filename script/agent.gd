#
# agent.gd is an unused class that describes a seeking agent with
# some basic properties, like a target to follow, and a path.
#

extends Node2D

export(int) var num_rays := 4
export(int) var look_ahead := 400
export(float) var max_angle := PI / 4
export(Array) var walk_points := []
export(PackedScene) var target_follow

var velocity := Vector2.ZERO
var target: Vector2
var follower


func _ready() -> void:
	var tf = target_follow.instance()
	tf.parent = self
	add_child(tf)


func _draw() -> void:
	draw_arc(Vector2.ZERO, 20, 0, PI * 2, 20, Color.aqua)
	draw_line(Vector2.ZERO, Vector2(20, 0), Color.aqua)


func _process(_delta: float):
	update()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_lmb"):
		set_target(get_global_mouse_position())


func get_target() -> Vector2:
	return target


func set_target(target: Vector2) -> void:
	self.target = target
