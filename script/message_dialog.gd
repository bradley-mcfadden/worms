extends PopupDialog


func _ready():
	popup_with_message("Did you know?", "Pee is stored in the balls")


func popup_with_message(title: String, message: String):
	$VBoxContainer/PanelContainer/VBoxContainer/Title.text = title
	$VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/Message.text = message
	popup()


func _on_Button_pressed():
	hide()
	$ButtonPressed.play()


func _on_MessageDialog_popup_hide():
	$MenuClosed.play()


func _on_Button_mouse_entered():
	$ButtonMouseEntered.play()
