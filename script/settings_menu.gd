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


func _on_Button_pressed(_option=false):
	$PressButton.play()


func _on_Button_mouse_entered():
	$FocusIn.play()


func _on_Button_toggled(state: bool):
	if state: $ButtonEnabled.play()
	else: $ButtonDisabled.play()


func _on_master_vol_drag_ended(changed: bool):
	if not changed: return
	var volume = $Menu/Tabs/audio/Cols/R/MasterVolumeSlider.value
	Configuration.set_master_volume(volume)


func _on_sfx_vol_drag_ended(changed: bool):
	if not changed: return
	var volume = $Menu/Tabs/audio/Cols/R/SoundFXVolumeSlider.value
	Configuration.set_sfx_volume(volume)


func _on_ui_vol_drag_ended(changed: bool):
	if not changed: return
	var volume = $Menu/Tabs/audio/Cols/R/UISoundVolumeSlider.value
	Configuration.set_ui_volume(volume)


func _on_music_vol_drag_ended(changed: bool):
	if not changed: return
	var volume = $Menu/Tabs/audio/Cols/R/MusicVolumeSlider.value
	Configuration.set_music_volume(volume)


func _on_slider_value_changed(_value: float):
	$SliderHandleMoved.play()


func _on_master_vol_value_changed(value: float):
	Configuration.set_master_volume(int(value))


func _on_music_vol_value_changed(value: float):
	Configuration.set_music_volume(int(value))


func _on_ui_vol_value_changed(value: float):
	Configuration.set_ui_volume(int(value))


func _on_sfx_vol_value_changed(value: float):
	Configuration.set_sfx_volume(int(value))


func _show_change_bind_for_action(action: String):
	pass


func _on_MoveForwardButton_pressed():
	_show_change_bind_for_action("move_forward")


func _on_TurnLeft_pressed():
	_show_change_bind_for_action("move_left")


func _on_TurnRight_pressed():
	_show_change_bind_for_action("move_right")


func _on_Ability1_pressed():
	_show_change_bind_for_action("ability1")


func _on_Ability2_pressed():
	_show_change_bind_for_action("ability2")


func _on_Ability3_pressed():
	_show_change_bind_for_action("ability3")


func _on_Ability4_pressed():
	_show_change_bind_for_action("ability4")


func _on_MoveUpALayer_pressed():
	_show_change_bind_for_action("change_layer_up")


func _on_MoveDownALayer_pressed():
	_show_change_bind_for_action("change_layer_down")


func _on_PeekUp_pressed():
	_show_change_bind_for_action("peek_layer_up")


func _on_PeekDown_pressed():
	_show_change_bind_for_action("peek_layer_down")


func _on_Restart_pressed():
	_show_change_bind_for_action("reset")


func _on_Interact_pressed():
	_show_change_bind_for_action("lay_eggs")
