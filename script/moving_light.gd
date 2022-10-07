#
# moving_light.gd
# Light that can be used for testing, it follows the mouse position.
#

extends Light2D


func _process(_delta: float) -> void:
	position = get_global_mouse_position()
