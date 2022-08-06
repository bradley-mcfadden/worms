extends MarginContainer


func _input(event):
	if Input.is_action_just_pressed("pause"):
		if self.visible:
			unpause()
		else:
			pause()


func pause():
	self.show()
	get_tree().paused = true


func unpause():
	self.hide()
	get_tree().paused = false


func _on_Resume_pressed():
	unpause()


func _on_Settings_pressed():
	pass


func _on_QuitToMenu_pressed():
	pass


func _on_QuitToDesktop_pressed():
	get_tree().quit()
