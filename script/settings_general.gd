#
# settings_general.gd
# Submenu of settings that handles settings that don't fit in other categories.
#

extends SettingsScrollContainer


signal update_labels


func _ready() -> void:
	_init_values()
	_init_connections()


func _init_values() -> void:
	$Cols/R/RichTextCheck.pressed = Configuration.sections["general"]["use_text_animations"]


func _init_connections() -> void:
	var check_buttons := [
		$Cols/R/RichTextCheck
	]
	for btn in check_buttons:
		btn.connect("button_toggled", self, "_on_button_toggled")
		btn.connect("focus_entered", self, "_on_control_focus_entered")
		btn.connect("focus_exited", self, "_on_control_focus_exited")


func _on_RichTextCheck_toggled(state: bool):
	Configuration.sections["general"]["use_text_animations"] = state
	emit_signal("update_labels")