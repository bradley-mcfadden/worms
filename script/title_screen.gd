#
# title_screen.gd controls the logic for getting the title screen ready
# and responding to UI events.
#

extends MarginContainer

const ANIMATION_OPEN_HEADER := "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER := "[/siny]"
const ANIMATION_OPEN_MSG := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG := "[/siny]"

# Path to "level select" scene
const LEVEL_SELECT_PATH := ""
# Path to "credits" scene
const CREDITS_PATH := "res://scene/GodotCredits.tscn"
# Path to "settings" scene
const SETTINGS_PATH = "res://scene/SettingsMenu.tscn"


func _ready() -> void:
	init_labels()


func init_labels() -> void:
	var animate = Configuration.sections["general"]["use_text_animations"]
	var header = $VBoxContainer/Header
	set_text(header, header.text, ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER, true, animate)


func set_text(
	label: RichTextLabel, msg: String, start: String, 
	end: String, center: bool = true, animate: bool = true) -> void:
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
	return "%s%s%s" % [start, string, end]


func _on_StartGame_pressed() -> void:
	# var first = Levels.first()
	# get_tree().change_scene(first)
	Levels.reset_index()
	print("Start level %d" % Levels.level_idx)
	var idx = Levels.next_index()
	print("Start level %d" % idx)
	var first = Levels.scene_from_index(idx)
	var file = File.new()
	if file.file_exists(first):
		var _ret = get_tree().change_scene(first)
	else:
		# Definitely an error
		pass


func _on_Settings_pressed() -> void:
	var settings = load(SETTINGS_PATH)
	var menu = settings.instance()
	menu.connect("tree_exited", self, "_on_Settings_exited")
	get_parent().add_child(menu)
	$VBoxContainer.hide()


func _on_Settings_exited() -> void:
	init_labels()
	$VBoxContainer.show()


func _on_LevelSelect_pressed() -> void:
	# get_tree.change_scene(LEVEL_SELECT_PATH)
	pass


func _on_Credits_pressed() -> void:
	var _ret = get_tree().change_scene(CREDITS_PATH)
	print(_ret)
	


func _on_QuitToDesktop_pressed() -> void:
	get_tree().quit()


func _on_Button_mouse_entered() -> void:
	$FocusIn.play()


func _on_Button_pressed() -> void:
	$PressButton.play()
