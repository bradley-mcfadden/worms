extends VBoxContainer

signal restart()

export (Array) var death_messages = ["the cycle yet continues"]


func _ready():
	var action = InputMap.get_action_list("reset")
	var key_string = OS.get_scancode_string(action[0].scancode)
	print(typeof(key_string))
	$RestartPrompt.text = "press '{str}' to restart".format({"str" : key_string})


func fade_in():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$Message.text = random_message()
	


func fade_out():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _input(_event):
	if visible:
		if Input.is_action_just_pressed("reset"):
			emit_signal("restart")


func random_message() -> String:
	return death_messages[rand_range(0, len(death_messages))]
