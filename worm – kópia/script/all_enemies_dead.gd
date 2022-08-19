extends VBoxContainer

signal lay_eggs()

const ANIMATION_OPEN_HEADER = "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER = "[/siny]"
const ANIMATION_OPEN_MSG = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG = "[/siny]"

func _ready():
	init_labels()


func fade_in():
	init_labels()


func fade_out():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _input(_event):
	if visible:
		if Input.is_action_just_pressed("lay_eggs"):
			emit_signal("lay_eggs")


func init_labels():
	var animate = Configuration.use_text_animations
	set_text(
		$Header, $Header.text, ANIMATION_OPEN_HEADER, 
		ANIMATION_CLOSE_HEADER, true, animate)
	var action = InputMap.get_action_list("lay_eggs")
	var key_string = OS.get_scancode_string(action[0].scancode)
	var rp_text = "press %s to lay eggs" % key_string
	set_text(
		$Message, rp_text, ANIMATION_OPEN_MSG, 
		ANIMATION_CLOSE_MSG, true, animate)


func set_text(label, msg, start, end, center=true, animate=true):
	var text = msg
	if center:
		text = wrap_string(msg, "[center]", "[/center]")
	
	if animate:
		text = wrap_string(text, start, end)
	
	label.bbcode_text = text


func wrap_string(string, start, end):
	return "%s%s%s" % [start, string, end] 
