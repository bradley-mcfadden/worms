#
# settings_scroll_container.gd
# Provides signals for common UI actions of submenus of settings. 
#

extends ScrollContainer


class_name SettingsScrollContainer


signal button_pressed
signal control_focus_entered
signal control_focus_exited
signal slider_handle_moved
signal button_enabled
signal button_disabled


func _on_control_focus_entered() -> void:
	emit_signal("control_focus_entered")


func _on_control_focus_exited() -> void:
	emit_signal("control_focus_exited")


func _on_button_pressed() -> void:
	emit_signal("button_pressed")


func _on_slider_handle_moved() -> void:
	emit_signal("slider_handle_moved")


func _on_button_toggled(state: bool) -> void:
	if state: emit_signal("button_enabled")
	else: emit_signal("button_disabled")
