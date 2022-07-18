extends VBoxContainer

signal lay_eggs()


func _ready():
	var action = InputMap.get_action_list("lay_eggs")
	var key_string = OS.get_scancode_string(action[0].scancode)
	print(typeof(key_string))
	$Message.text = "press '{str}' to lay eggs".format({"str" : key_string})


func fade_in():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func fade_out():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _input(_event):
	if visible:
		if Input.is_action_just_pressed("lay_eggs"):
			emit_signal("lay_eggs")
