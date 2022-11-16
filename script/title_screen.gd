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
	$Tween.interpolate_property(self, "modulate", Color.black, Color.white, 1.0)
	$Tween.start()
	init_labels()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GraphicsConfigLoader.call_deferred("use_default_resolution")
	yield($Tween, "tween_completed")
	$VBoxContainer/StartGame.disabled = false
	$VBoxContainer/Settings.disabled = false
	$VBoxContainer/LevelSelect.disabled = false
	$VBoxContainer/Credits.disabled = false
	$VBoxContainer/QuitToDesktop.disabled = false


func init_labels() -> void:
	var animate: bool = Configuration.sections["general"]["use_text_animations"]
	var header: RichTextLabel = $VBoxContainer/Header
	set_text(header, header.text, ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER, true, animate)


func fade_in() -> void:
	pass

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
	var text := msg
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
	Levels.reset_index()
	$Tween.interpolate_property(self, "modulate", null, Color.black, 1.0)
	$Tween.start()
	Levels.call_deferred("next_level_or_main")


func _on_Settings_pressed() -> void:
	var settings = load(SETTINGS_PATH)
	var menu = settings.instance()
	menu.connect("exiting", self, "_on_Settings_exiting")
	get_parent().add_child(menu)
	$VBoxContainer.hide()
	$VBoxContainer.modulate = Color.transparent


func _on_Settings_exiting() -> void:
	init_labels()
	$VBoxContainer.show()
	$Tween.interpolate_property($VBoxContainer, "modulate", null, Color.white, 0.5)
	$Tween.start()


func _on_LevelSelect_pressed() -> void:
	# get_tree.change_scene(LEVEL_SELECT_PATH)
	pass


func _on_Credits_pressed() -> void:
	$Tween.interpolate_property(self, "modulate", null, Color.black, 2.0)
	$Tween.start()
	yield($Tween, "tween_completed")
	var _ret = get_tree().change_scene(CREDITS_PATH)


func _on_QuitToDesktop_pressed() -> void:
	print("Quit to desktop")
	$Tween.interpolate_property(self, "modulate", null, Color.black, 2.0)
	$Tween.start()
	yield($Tween, "tween_completed")
	get_tree().quit()


func _on_Button_mouse_entered() -> void:
	if not $Tween.is_active():
		$FocusIn.play()


func _on_Button_pressed() -> void:
	$PressButton.play()


func fade_out() -> void:
	$Tween.interpolate_property(self, "modulate", null, Color.black, 2.0)
	$Tween.start()
	yield($Tween, "tween_completed")
