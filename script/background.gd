# background.gd is attached to a sprite and is used to
# hold some state variables that track how fast the scrolling
# material moves.

extends Sprite

export var scroll_speed := Vector2(1.0, 1.0)

var last_tracked_position := Vector2(0, 0)
var max_tracked_speed := Vector2(1, 1)


func _ready() -> void:
	pass


func update_tracked_position(new_position: Vector2) -> void:
#
# update_tracked_position to a new position. The apparent speed of the
# texture's scroll is also updated.
# 
# new_position - A position to move to.
#
	var mag: Vector2 = (new_position - last_tracked_position) / max_tracked_speed
	last_tracked_position = new_position
	self.material.set_shader_param("scroll_speed", mag)
