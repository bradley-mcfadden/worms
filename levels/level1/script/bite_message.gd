extends "res://script/proximity_message.gd"


func _ready() -> void:
	var actions: Array = InputMap.get_action_list("ability2")
	var bind_str: String = InputLoader.string_from_event(actions[0])
	$Label.text = "Press %s once to open mouth,\ntwice to bite" % bind_str
