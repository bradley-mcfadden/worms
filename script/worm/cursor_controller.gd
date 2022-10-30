#
# cursor_controller.gd
#
# Alternate input controller that allows for steering the worm with a cursor.
# The worm steers automatically toward the cursor.
# TODO: Set up different keybinds for this control scheme.
# TODO: Support moving cursor with a joystick.
#

extends WormController


# Difference in head rotation and direction to cursor before steering is applied.
export (float) var turn_threshold := PI / 16
var following: Node2D = null


func _physics_process(_delta: float) -> void:
	if not following == null: 
		# unit vector between following and self
		var direction: Vector2 = $Cursor.cursor_position - following.global_position
		direction = direction.normalized()

		var following_dir := Vector2.RIGHT.rotated(following.global_rotation)
		var direction_diff: float = direction.angle_to(following_dir) * -1
		if direction_diff < -turn_threshold:
			replace_action_map_value("move_left", true)
		elif direction_diff > turn_threshold:
			replace_action_map_value("move_right", true)
		else:
			replace_action_map_value("move_left", false)
			replace_action_map_value("move_right", false)
	
	for key in curr_action_map.keys():
		if not key in ["move_left", "move_right"]:
			replace_action_map_value(key, Input.is_action_pressed(key))


func correct_angle(angle: float) -> float:
#
# correct_angle converts a possibly negative angle to an always positve one by adding 2PI.
# angle - Potentially negative angle.
# return - Angle in range [0, 2PI)
# 
	if angle < 0:
		angle += 2 * PI
	return angle
