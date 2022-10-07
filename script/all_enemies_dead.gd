# all_enemies_dead appears when the player beats the level. 
# It provides a prompt and a message. Accepting the prompt triggers the lay_eggs signal
# that causes the level to end.

extends VBoxContainer

# Emitted when player has accepted prompt
signal lay_eggs

const ANIMATION_OPEN_HEADER := "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER := "[/siny]"
const ANIMATION_OPEN_MSG := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG := "[/siny]"


func _ready() -> void:
	init_labels()


func fade_in() -> void:
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
		if Input.is_action_just_pressed("lay_eggs"):
			emit_signal("lay_eggs")


func init_labels() -> void:
	var animate = Configuration.use_text_animations
	set_text($Header, $Header.text, ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER, true, animate)
	var action = InputMap.get_action_list("lay_eggs")
	var key_string = OS.get_scancode_string(action[0].scancode)
	var rp_text = "press %s to lay eggs" % key_string
	set_text($Message, rp_text, ANIMATION_OPEN_MSG, ANIMATION_CLOSE_MSG, true, animate)


func set_text(
	label: RichTextLabel, msg: String, start: String, end: String, 
	center: bool = true, animate: bool = true):
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
