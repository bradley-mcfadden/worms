#
# message_dialog.gd
# Used to show a dialog with a title, message, and a button to the player.
#

extends PopupDialog


func popup_with_message(title: String, message: String) -> void:
#
# popup_with_message 
# Show the dialog with a title, message, and a close button.
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
