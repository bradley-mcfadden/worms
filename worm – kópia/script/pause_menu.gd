extends MarginContainer

signal show_settings_pressed()

var use_animations = true
const ANIMATION_OPEN_HEADER = "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER = "[/siny]"
const ANIMATION_OPEN_MSG = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG = "[/siny]"


func _ready():
	init_labels()


func _input(event):
	if Input.is_action_just_pressed("pause"):
		if self.visible:
			unpause()
		else:
			pause()


func init_labels():
	set_text($VBoxContainer/Label, $VBoxContainer/Label.text, ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER)


func pause():
	self.show()
	get_tree().paused = true
	init_labels()


func unpause():
	self.hide()
	get_tree().paused = false


func _on_Resume_pressed():
	unpause()


func _on_Settings_pressed():
	pass


func _on_QuitToMenu_pressed():
	# get_tree().change_scene('something')
	pass


func _on_QuitToDesktop_pressed():
	get_tree().quit()


func set_text(label, msg, start, end, center=true):
	var text = msg
	if center:
		text = wrap_string(msg, "[center]", "[/center]")
	
	if use_animations:
		text = wrap_string(text, start, end)
	
	label.bbcode_text = text


func wrap_string(string, start, end):
	return "%s%s%s" % [start, string, end] 
