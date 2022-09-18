extends MarginContainer

const ANIMATION_OPEN_HEADER = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER = "[/siny]"
const ANIMATION_OPEN_MSG = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG = "[/siny]"

onready var general = $Menu/Tabs/general
onready var controls = $Menu/Tabs/controls
onready var graphics = $Menu/Tabs/graphics
onready var audio = $Menu/Tabs/audio


func _ready():
	init_labels()
	init_controls()


func init_labels():
	set_text(
		$Menu/Title,
		$Menu/Title.text,
		ANIMATION_OPEN_HEADER,
		ANIMATION_CLOSE_HEADER,
		true,
		Configuration.use_text_animations
	)


func init_controls():
	general.get_node("Cols/R/RichTextCheck").pressed = Configuration.use_text_animations


func set_text(label, msg, start, end, center = true, animate = true):
	var text = msg
	if center:
		text = wrap_string(msg, "[center]", "[/center]")

	if animate:
		text = wrap_string(text, start, end)

	label.bbcode_text = text


func wrap_string(string, start, end):
	return "%s%s%s" % [start, string, end]


func _on_RichTextCheck_toggled(state: bool):
	Configuration.use_text_animations = state
	init_labels()


func _on_ExitButton_pressed():
	queue_free()


func _on_Button_pressed():
	$PressButton.play()


func _on_Button_mouse_entered():
	$FocusIn.play()


func _on_Button_toggled(state: bool):
	if state: $ButtonEnabled.play()
	else: $ButtonDisabled.play()
