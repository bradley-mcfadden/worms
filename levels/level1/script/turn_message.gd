extends "res://script/proximity_message.gd"


func _ready() -> void:
	var scheme: String = Configuration.sections["controls"]["current_scheme"]
	visible = scheme == "keyboard"
	var left_actions := InputMap.get_action_list("move_left")
	var left_string: String = InputLoader.string_from_event(left_actions[0])
	var right_actions := InputMap.get_action_list("move_right")
	var right_string: String = InputLoader.string_from_event(right_actions[0])
	$Label.text = "Press %s to turn left\nPress %s to turn right" % [left_string, right_string]
