#
# death_screen.gd appears when the player has expired. It prompts the user
# to press a button to restart the level, and emits the restart signal.
#

extends VBoxContainer

# Signal emitted when player wishes to restart
signal restart

const ANIMATION_OPEN_HEADER := "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER := "[/siny]"
const ANIMATION_OPEN_MSG := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG := "[/siny]"

export(Array) var death_messages := ["the cycle yet continues"]


func _ready() -> void:
	init_labels()


func init_labels() -> void:
	var animate = Configuration.sections["general"]["use_text_animations"]
	set_text(
		$Message, random_message(), ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER, true, animate
	)
	var action: Array = InputMap.get_action_list("reset")
	var key_string: String = InputLoader.string_from_event(action[0])
	var rp_text = "press %s to restart" % key_string
	set_text(
		$RestartPrompt, rp_text, ANIMATION_OPEN_MSG, ANIMATION_CLOSE_MSG, true, animate
	)


func fade_in() -> void:
	$Tween.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$Tween.start()
	init_labels()


func fade_out() -> void:
	$Tween.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$Tween.start()


func _input(_event: InputEvent) -> void:
	if visible:
		if Input.is_action_just_pressed("reset"):
			emit_signal("restart")


func random_message() -> String:
# random_message produces a random message for the screen from the list of
# death messages.
#
# return - A random death message.
	var msg = death_messages[rand_range(0, len(death_messages))]
	return msg


func set_text(label: RichTextLabel, msg: String, start: String, end: String, center: bool = true, animate: bool = true) -> void:
#
# set_text formats a msg in a rich text label with the start and end bbcode.
# label - To change text of.
# msg - Msg that the user should see
# start - Start bbcode string
# end - Closing bbcode string
# center - If the text should should be centered
# animate - If start and end should be appended
#
	var text = msg
	if center:
		text = wrap_string(msg, "[center]", "[/center]")

	if animate:
		text = wrap_string(text, start, end)

	label.bbcode_text = text


func wrap_string(string: String, start: String, end: String) -> String:
#
# wrap_string wraps string with start and end string tokens 
# return - <start><string><end>
#
	return "%s%s%s" % [start, string, end]
