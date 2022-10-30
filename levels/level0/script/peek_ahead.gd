extends "res://script/proximity_message.gd"


func _ready() -> void:
	var actions: Array = InputMap.get_action_list("look_ahead")
	var bind_string : String = InputLoader.string_from_event(actions[0])
	$Label.text = "Press %s to look ahead of your position" % bind_string

