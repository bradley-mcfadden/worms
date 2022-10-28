extends "res://script/proximity_message.gd"


func _ready() -> void:
	var down_actions: Array = InputMap.get_action_list("layer_down")
	var down_str: String = InputLoader.string_from_event(down_actions[0])
	var p_down_actions: Array = InputMap.get_action_list("peek_layer_down")
	var p_down_str: String = InputLoader.string_from_event(p_down_actions[0])
	$Label.text = "Press %s to descend,\nand %s to peek underground" % [down_str, p_down_str]
