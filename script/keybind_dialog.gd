# Dialog for changing keybinds.
# User can see what action they're changing, and what key they
# will change it to. Can cancel by pressing clicking off dialog.

extends "res://script/message_dialog.gd"


var current_action := ""
var new_input_event: InputEvent = null


func show_for(action: String, action_desc: String):
	# Show dialog with action_desc in title,
	# and make action the current action.
	var title := "Change keybind for " + action_desc
	var message := "Press any button"
	current_action = action
	popup_with_message(title, message)


func set_message(message: String):
	$VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/Message.text = message


func _input(event: InputEvent) -> void:
	# Record the most recent key press and update message.
	if event is InputEventKey:
		var code = event.scancode
		set_message('\'%s\'' % OS.get_scancode_string(code))
		new_input_event = event


func _on_popup_hide():
	# Do not save, just cancel the action
	if new_input_event != null:
		new_input_event = null
		current_action = ""


func _on_OkButton_pressed():
	# Save the change to settings and close dialog
	if new_input_event != null:
		InputMap.action_erase_events(current_action)
		InputMap.action_add_event(current_action, new_input_event)
		var property_name = "input/%s" % current_action
		var action_cfg = ProjectSettings.get_setting(property_name)
		action_cfg["events"] = InputMap.get_action_list(current_action)
		ProjectSettings.set_setting(property_name, action_cfg)
		var _ret = ProjectSettings.save_custom("override.cfg")
		new_input_event = null
		current_action = ""
