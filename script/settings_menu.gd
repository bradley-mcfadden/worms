#
# settings_menu.gd 
# Contains code for handling UI events from SettingsMenu.
# This should probably be split into five files, one for each
# settings tab, and a main one.
#
extends MarginContainer

const ANIMATION_OPEN_HEADER = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER = "[/siny]"
const ANIMATION_OPEN_MSG = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG = "[/siny]"

onready var general = $Menu/Tabs/general
onready var controls = $Menu/Tabs/controls
onready var graphics = $Menu/Tabs/graphics
onready var audio = $Menu/Tabs/audio


func _ready() -> void:
	init_labels()
	init_values()


func init_labels() -> void:
	set_text(
		$Menu/Title,
		$Menu/Title.text,
		ANIMATION_OPEN_HEADER,
		ANIMATION_CLOSE_HEADER,
		true,
		Configuration.sections["general"]["use_text_animations"]
	)


func _on_update_labels() -> void:
	init_labels()


func init_values() -> void:
# 
# initialize values to their most up to date setting.
#	
#	# general here
	general.get_node("Cols/R/RichTextCheck").pressed = Configuration.sections["general"]["use_text_animations"]
	# graphics here
	# controls here
	# audio here
	audio.get_node("Cols/R/MasterVolumeSlider").value = Configuration.sections["audio"]["master_volume"]
	audio.get_node("Cols/R/SoundFXVolumeSlider").value = Configuration.section["audio"]["sfx_volume"]
	audio.get_node("Cols/R/UISoundVolumeSlider").value = Configuration.sections["audio"]["ui_volume"]
	audio.get_node("Cols/R/MusicVolumeSlider").value = Configuration.sections["audio"]["music_volume"]


func set_text(label: Node, msg: String, start: String, end, center: bool = true, animate: bool = true) -> void:
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


func _on_ExitButton_pressed() -> void:
	hide()
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()


func _on_Button_pressed(_option: bool = false) -> void:
	$PressButton.play()


func _on_Button_mouse_entered() -> void:
	$FocusIn.play()


func _on_Button_toggled(state: bool) -> void:
	if state: $ButtonEnabled.play()
	else: $ButtonDisabled.play()


func _on_slider_value_changed(_value: float) -> void:
	$SliderHandleMoved.play()


func _on_change_binding_requested(action: String, desc: String) -> void:
	$KeybindDialog.show_for(action, desc)


func _on_Tabs_tab_changed(tab: int) -> void:
	match tab:
		1: _on_Controls_shown()


func _on_Controls_shown() -> void:
	$Menu/Tabs/controls.show()
