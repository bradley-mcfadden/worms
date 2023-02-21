#
# pause_menu.gd
# Script for managing UI for the pause menu.
#
extends MarginContainer

# Emitted when game has been unpaused.
signal unpaused
# Emitted when game is just paused.
signal paused

const ANIMATION_OPEN_HEADER := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER := "[/siny]"
const ANIMATION_OPEN_MSG := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG := "[/siny]"

const MAIN_MENU_PATH := "res://scene/ui/TitleScreen.tscn"
const SETTINGS_PATH := "res://scene/ui/SettingsMenu.tscn"


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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	emit_signal("paused")


func unpause(emit: bool = true) -> void:
	self.hide()
	get_tree().paused = false
	var scheme: String = Configuration.sections["controls"]["current_scheme"]
	if scheme == "mouse_keyboard":
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	InputLoader.load_mappings()
	if emit:
		emit_signal("unpaused")


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
	#var _x = get_tree().change_scene(MAIN_MENU_PATH)
	#print(_x)
	print("Quitting to menu")
	unpause(false)
	AsyncLoader.load_resource(MAIN_MENU_PATH)
	var _r: int = AsyncLoader.connect("resource_loaded", self, "_on_resource_loaded")


func _on_resource_loaded(path: String, resource: Resource) -> void:
	if path == MAIN_MENU_PATH:
		print("Changing scene to main menu")
		AsyncLoader.disconnect("resource_loaded", self, "_on_resource_loaded")
		AsyncLoader.change_scene_to(resource)
		print("Done changing to main menu")
		

func _on_QuitToDesktop_pressed() -> void:
	print("Quitting to desktop")
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
