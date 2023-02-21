#
# confirm_dialog.gd
# Used to show a dialog with a title, message, and two buttons.
# Signals are emitted that indicate the pressed button.
#

extends PopupDialog


# Emitted when confirm button is pressed
signal confirmed
# Emitted when deny button is pressed
signal denied


func _ready() -> void:
	var buttons := [
		$VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Deny,
		$VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/Confirm,
	]
	for btn in buttons:
		btn.connect("pressed", self, "_on_Button_pressed")
		btn.connect("mouse_entered", self, "_on_Button_mouse_entered")



func popup_with_message(title: String, message: String) -> void:
#
# popup_with_message 
# Show the dialog with a title, message, and a close/accept button.
# title - Displayed at top of dialog.
# message - Displayed in center of dialog.
#
	$VBoxContainer/PanelContainer/VBoxContainer/Title.text = title
	$VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/Message.text = message
	popup()


func _on_Button_pressed() -> void:
	hide()
	$ButtonPressed.play()


func _on_MessageDialog_popup_hide() -> void:
	$MenuClosed.play()


func _on_Button_mouse_entered() -> void:
	$ButtonMouseEntered.play()


func _on_Deny_pressed() -> void:
	emit_signal("denied")
	hide()


func _on_Confirm_pressed() -> void:
	emit_signal("confirmed")
