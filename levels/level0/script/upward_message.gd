extends "res://script/proximity_message.gd"


func _ready() -> void:
	var up_actions: Array = InputMap.get_action_list("layer_up")
	var up_str: String = InputLoader.string_from_event(up_actions[0])
	var p_up_actions: Array = InputMap.get_action_list("peek_layer_up")
	var p_up_str: String = InputLoader.string_from_event(p_up_actions[0])
	$Label.text = "Press %s to peek above ground,\n and %s to travel above ground" % [p_up_str, up_str]
