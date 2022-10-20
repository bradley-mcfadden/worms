#
# settings_controls.gd 
# is a script for fetching the key bindings, 
# and initializing the UI with them
#
extends SettingsScrollContainer

# Emitted when a binding is requested to be changed
signal change_binding_requested(name, label) # String, String


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


func _ready() -> void:
	_init_values()
	_init_connections()


func _init_values() -> void:
	_get_controls()


func _init_connections() -> void:
	var buttons := [
		$Cols/RightColumn/RestoreDefaults
	]
	var rcol: Node = $Cols/RightColumn
	for key in button_to_action.keys():
		var button: Button = rcol.get_node(key)
		buttons.append(button)
	
	for btn in buttons:
		btn.connect("focus_entered", self, "_on_control_focus_entered")
		btn.connect("focus_exited", self, "_on_control_focus_exited")
		btn.connect("pressed", self, "_on_button_pressed")


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


func _show_change_bind_for_action(action: String, label: String) -> void:
	emit_signal("change_binding_requested", action, label)


func _on_MoveForwardButton_pressed() -> void:
	_show_change_bind_for_action("move_forward", '"move forward"')


func _on_TurnLeft_pressed() -> void:
	_show_change_bind_for_action("move_left", '"move left"')


func _on_TurnRight_pressed() -> void:
	_show_change_bind_for_action("move_right", '"move right"')


func _on_Ability1_pressed() -> void:
	_show_change_bind_for_action("ability1", '"use ability 1"')


func _on_Ability2_pressed() -> void:
	_show_change_bind_for_action("ability2", '"use ability 2"')


func _on_Ability3_pressed() -> void:
	_show_change_bind_for_action("ability3", '"use ability 3"')


func _on_Ability4_pressed() -> void:
	_show_change_bind_for_action("ability4", '"use ability 4"')


func _on_MoveUpALayer_pressed() -> void:
	_show_change_bind_for_action("change_layer_up", '"move up a layer"')


func _on_MoveDownALayer_pressed() -> void:
	_show_change_bind_for_action("change_layer_down", '"move down a layer"')


func _on_PeekUp_pressed() -> void:
	_show_change_bind_for_action("peek_layer_up", '"peek up a layer"')


func _on_PeekDown_pressed() -> void:
	_show_change_bind_for_action("peek_layer_down", '"peek down a layer"')


func _on_Restart_pressed() -> void:
	_show_change_bind_for_action("reset", '"restart level"')


func _on_Interact_pressed() -> void:
	_show_change_bind_for_action("lay_eggs", '"interact"')
