extends MarginContainer

const ANIMATION_OPEN_HEADER = "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER = "[/siny]"
const ANIMATION_OPEN_MSG = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG = "[/siny]"

const LEVEL_SELECT_PATH = ""
const CREDITS_PATH = ""

func _ready():
	init_labels()


func init_labels():
	var animate = Configuration.use_text_animations
	var header = $VBoxContainer/Header
	set_text(header, header.text, ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER, animate)


func set_text(label, msg, start, end, center=true, animate=true):
	var text = msg
	if center:
		text = wrap_string(msg, "[center]", "[/center]")
	
	if animate:
		text = wrap_string(text, start, end)
	
	label.bbcode_text = text


func wrap_string(string, start, end):
	return "%s%s%s" % [start, string, end]


func _on_StartGame_pressed():
	# var first = Levels.first()
	# get_tree().change_scene(first)
	pass


func _on_Settings_pressed():
	# Settings.show()
	pass


func _on_LevelSelect_pressed():
	# get_tree.change_scene(LEVEL_SELECT_PATH)
	pass


func _on_Credits_pressed():
	# get_tree.change_scene(CREDITS_PATH)
	pass


func _on_QuitToDesktop_pressed():
	get_tree().quit()
