extends MarginContainer

const ANIMATION_OPEN_HEADER = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER = "[/siny]"
const ANIMATION_OPEN_MSG = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG = "[/siny]"

const MAIN_MENU_PATH = "res://Scene/TitleScreen.tscn"
const SETTINGS_PATH = "res://Scene/SettingsMenu.tscn"


func _ready():
	init_labels()


func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if self.visible:
			unpause()
		else:
			pause()


func init_labels():
	set_text(
		$VBoxContainer/Label,
		$VBoxContainer/Label.text,
		ANIMATION_OPEN_HEADER,
		ANIMATION_CLOSE_HEADER,
		true,
		Configuration.use_text_animations
	)


func pause():
	self.show()
	get_tree().paused = true
	init_labels()


func unpause():
	self.hide()
	get_tree().paused = false


func _on_Resume_pressed():
	unpause()


func _on_Settings_pressed():
	var settings = load(SETTINGS_PATH)
	var menu = settings.instance()
	menu.connect("tree_exited", self, "_on_Settings_exited")
	get_parent().add_child(menu)
	$VBoxContainer.hide()


func _on_Settings_exited():
	init_labels()
	$VBoxContainer.show()


func _on_QuitToMenu_pressed():
	get_tree().change_scene(MAIN_MENU_PATH)


func _on_QuitToDesktop_pressed():
	get_tree().quit()


func set_text(label, msg, start, end, center = true, animate = true):
	var text = msg
	if center:
		text = wrap_string(msg, "[center]", "[/center]")

	if animate:
		text = wrap_string(text, start, end)

	label.bbcode_text = text


func wrap_string(string, start, end):
	return "%s%s%s" % [start, string, end]
