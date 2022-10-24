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


func _ready() -> void:
	init_labels()
	_init_connections()


func init_labels() -> void:
	set_text(
		$Menu/Title,
		$Menu/Title.text,
		ANIMATION_OPEN_HEADER,
		ANIMATION_CLOSE_HEADER,
		true,
		Configuration.sections["general"]["use_text_animations"]
	)


func _init_connections() -> void:
	var sub_menus := [
		$Menu/Tabs/general,
		$Menu/Tabs/controls,
		$Menu/Tabs/audio,
		$Menu/Tabs/graphics
	]

	for menu in sub_menus:
		var _res
		_res = menu.connect("button_pressed", self, "_on_button_pressed")
		_res = menu.connect("control_focus_entered", self, "_on_control_focus_entered")
		_res = menu.connect("control_focus_exited", self, "_on_control_focus_exited")
		_res = menu.connect("slider_handle_moved", self, "_on_slider_handle_moved")
		_res = menu.connect("button_enabled", self, "_on_button_enabled")
		_res = menu.connect("button_disabled", self, "_on_button_disabled")


func _on_update_labels() -> void:
	init_labels()


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


func _on_button_pressed(_unused: bool = false) -> void:
	$PressButton.play()


func _on_control_focus_entered() -> void:
	$FocusIn.play()


func _on_control_focus_exited() -> void:
	pass


func _on_slider_handle_moved() -> void:
	$SliderHandleMoved.play()


func _on_button_enabled() -> void:
	$ButtonEnabled.play()


func _on_button_disabled() -> void:
	$ButtonDisabled.play()


func _on_change_binding_requested(action: String, desc: String) -> void:
	print("action ", action, " ", desc)
	$KeybindDialog.show_for(action, desc)


func _on_Tabs_tab_changed(tab: int) -> void:
	match tab:
		1: _on_Controls_shown()


func _on_Controls_shown() -> void:
	$Menu/Tabs/controls.show()
