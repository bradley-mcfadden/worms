extends "res://script/proximity_message.gd"


func _ready() -> void:
	var actions: Array = InputMap.get_action_list("ability1")
	var bind_str: String = InputLoader.string_from_event(actions[0])
	$Label.text = "Press %s for a speed boost" % bind_str
