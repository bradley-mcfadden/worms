extends MarginContainer

const ANIMATION_OPEN_HEADER = "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER = "[/siny]"
const ANIMATION_OPEN_MSG = "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG = "[/siny]"

const LEVEL_SELECT_PATH = ""
const CREDITS_PATH = ""

const SETTINGS_PATH = "res://Scene/SettingsMenu.tscn"


func _ready():
	init_labels()


func init_labels():
	var animate = Configuration.use_text_animations
	var header = $VBoxContainer/Header
	set_text(header, header.text, ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER, true, animate)


func set_text(label, msg, start, end, center = true, animate = true):
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
	Levels.reset_index()
	print("Start level %d" % Levels.level_idx)
	var idx = Levels.next_index()
	print("Start level %d" % idx)
	print(str(idx))
	var first = Levels.scene_from_index(idx)
	var file = File.new()
	if file.file_exists(first):
		get_tree().change_scene(first)
	else:
		# Definitely an error
		pass


func _on_Settings_pressed():
	var settings = load(SETTINGS_PATH)
	var menu = settings.instance()
	menu.connect("tree_exited", self, "_on_Settings_exited")
	get_parent().add_child(menu)
	$VBoxContainer.hide()


func _on_Settings_exited():
	init_labels()
	$VBoxContainer.show()


func _on_LevelSelect_pressed():
	# get_tree.change_scene(LEVEL_SELECT_PATH)
	pass


func _on_Credits_pressed():
	# get_tree.change_scene(CREDITS_PATH)
	pass


func _on_QuitToDesktop_pressed():
	get_tree().quit()
