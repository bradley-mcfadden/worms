#
# move_light.gd should be attached to a Light2D to make it follow the
# mouse cursor.


extends Light2D


func _process(_delta: float) -> void:
	position = get_global_mouse_position()
