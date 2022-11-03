extends "res://script/proximity_message.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scheme: String = Configuration.sections["controls"]["current_scheme"]
	visible = scheme == "mouse_keyboard"
