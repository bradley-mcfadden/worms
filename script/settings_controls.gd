#
# settings_controls.gd 
# is a script for fetching the key bindings, 
# and initializing the UI with them
#
extends ScrollContainer


onready var button_to_action := {
	"MoveForwardButton" : "move_forward",
	"TurnLeft" : "move_left",
	"TurnRight" : "move_right",
	"Ability1" : "ability1",
	"Ability2" : "ability2",
	"Ability3" : "ability3",
	"Ability4" : "ability4",
	"MoveUpALayer" : "layer_up",
	"MoveDownALayer" : "layer_down",
	"PeekUp" : "peek_layer_up",
	"PeekDown" : "peek_layer_down",
	"Restart" : "reset",
	"Interact" : "lay_eggs",
}

func show() -> void:
	_get_controls()
	.show()


func _get_controls() -> void:
#
# _get_controls - Initialize buttons in button_to_action with scancode strings
# 
	print(_keystr_for("move_forward"))
	var rcol = $Cols/RightColumn
	for key in button_to_action.keys():
		var button = rcol.get_node(key)
		button.text = _keystr_for(button_to_action[key])


func _keystr_for(action: String) -> String:
#
# _key_str_for - return scancode string for a particular action
# action - Name of action 
# return - scancode string or ???
	var first: InputEvent = InputMap.get_action_list(action)[0]
	if first is InputEventKey:
		return OS.get_scancode_string(first.scancode)
	else:
		return '???'


func _on_RestoreDefaults_pressed():
# Restore defaults with initial property values
	var file = Directory.new()
	if file.file_exists("override.cfg"):
		file.remove()
