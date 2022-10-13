#
# pause_menu.gd
# Script for managing UI for the pause menu.
#
extends MarginContainer

const ANIMATION_OPEN_HEADER := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER := "[/siny]"
const ANIMATION_OPEN_MSG := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG := "[/siny]"

const MAIN_MENU_PATH := "res://Scene/TitleScreen.tscn"
const SETTINGS_PATH := "res://Scene/SettingsMenu.tscn"


func _ready() -> void:
	init_labels()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if self.visible:
			unpause()
		else:
			pause()


func init_labels() -> void:
	set_text(
		$VBoxContainer/Label,
		$VBoxContainer/Label.text,
		ANIMATION_OPEN_HEADER,
		ANIMATION_CLOSE_HEADER,
		true,
		Configuration.sections["general"]["use_text_animations"]
	)


func pause() -> void:
	self.show()
	get_tree().paused = true
	init_labels()


func unpause() -> void:
	self.hide()
	get_tree().paused = false


func _on_Resume_pressed() -> void:
	unpause()


func _on_Settings_pressed() -> void:
	var settings = load(SETTINGS_PATH)
	var menu = settings.instance()
	menu.connect("tree_exited", self, "_on_Settings_exited")
	get_parent().add_child(menu)
	$VBoxContainer.hide()


func _on_Settings_exited() -> void:
	init_labels()
	$VBoxContainer.show()


func _on_QuitToMenu_pressed() -> void:
	unpause()
	var _x = get_tree().change_scene(MAIN_MENU_PATH)


func _on_QuitToDesktop_pressed() -> void:
	get_tree().quit()


func set_text(
	label: RichTextLabel, msg: String, start: String, end: String, 
	center: bool = true, animate: bool = true
) -> void:
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


func _on_Button_pressed() -> void:
	$PressButton.play()


func _on_Button_mouse_entered() -> void:
	$FocusIn.play()
