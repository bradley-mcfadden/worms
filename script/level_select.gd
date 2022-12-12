extends Control


const ANIMATION_OPEN_HEADER := "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER := "[/siny]"
const ANIMATION_OPEN_MSG := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG := "[/siny]"

const SKIN_SELECT_PATH := "res://scene/SkinSelect.tscn"
const TITLE_SCREEN_PATH := "res://scene/TitleScreen.tscn"


func _ready() -> void:
	Levels.level_idx = 0
	
	_init_connections()
	var label := $LevelInfo/Title
	set_text(label, label.text, ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _init_connections() -> void:
	var previous_world_btn: Button = $LevelInfo/World/Previous
	var _ret = previous_world_btn.connect("pressed", self, "_on_prev_world_pressed")
	
	var next_world_btn: Button = $LevelInfo/World/Next
	_ret = next_world_btn.connect("pressed", self, "_on_next_world_pressed")
		
	var prev_level_btn: Button = $LevelInfo/Level/Previous
	_ret = prev_level_btn.connect("pressed", self, "_on_prev_level_pressed")
	
	var next_level_btn: Button = $LevelInfo/Level/Next
	_ret = next_level_btn.connect("pressed", self, "_on_next_level_pressed")
	
	var back_btn: Button = $Back
	_ret = back_btn.connect("pressed", self, "_on_back_pressed")
	
	var skins_btn: Button = $Skins
	_ret = skins_btn.connect("pressed", self, "_on_skins_pressed")

	var worm = $ViewportContainer/Viewport/SpawnKinematic
	_ret = worm.connect("ready", self, "_on_worm_ready")
	worm.background = $Background
	
	var start_btn: Button = $Start
	_ret = start_btn.connect("pressed", self, "_on_start_button_pressed")


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


func _init_from_level_config() -> void:
	var config: Dictionary = Levels.config_from_index(Levels.level_idx)
	var level_title: String = config['properties']['name']
	var world_title: String = config['properties']['world']
	
	$LevelInfo/Level/Name.text = level_title
	$LevelInfo/World/Name.text = world_title
	
	var total_eggs: int = config['properties']['neggs']
	var total_fossils: int = config['properties']['nfossils']
	
	var n_eggs: int
	var n_fossils: int
	var time_str: String = "not cleared"
	if config.has('previous'): 
		n_eggs = config['previous']['neggs']
		n_fossils = config['previous']['nfossils']
		time_str = config['previous']['time']
	else:
		n_eggs = 0
		n_fossils = 0
		
	$Tally/Eggs.text = "%d/%d" % [n_eggs, total_eggs]
	$Tally/Fossils.text = "%d/%d" % [n_fossils, total_fossils]
	$Tally/Time.text = time_str


func _on_prev_world_pressed() -> void:
	$Sounds/NavigateBackward.play()


func _on_next_world_pressed() -> void:
	$Sounds/NavigateForward.play()


func _on_prev_level_pressed() -> void:
	$Sounds/NavigateBackward.play()
	var prev_idx: int = Levels.level_idx
	Levels.level_idx = Levels.level_idx - 1 % len(Levels.get_level_list())
	
	if prev_idx != Levels.level_idx:
		_init_from_level_config()


func _on_next_level_pressed() -> void:
	$Sounds/NavigateForward.play()
	var prev_idx: int = Levels.level_idx
	Levels.level_idx = Levels.level_idx + 1 % len(Levels.get_level_list())
	
	if prev_idx != Levels.level_idx:
		_init_from_level_config()


func _on_skins_pressed() -> void:
	$Sounds/PressButton.play()
	change_to_scene(SKIN_SELECT_PATH)


func _on_back_pressed() -> void:
	$Sounds/PressButton.play()
	change_to_scene(TITLE_SCREEN_PATH)


func change_to_scene(path: String) -> void:
	var _ret = AsyncLoader.connect("resource_loaded", self, "_on_resource_loaded")
	AsyncLoader.load_resource(path)


func _on_resource_loaded(path: String, resource: Resource) -> void:
	AsyncLoader.change_scene_to(resource)
	AsyncLoader.disconnect("resource_loaded", self, "_on_resource_loaded")


func _on_worm_ready() -> void:
	var color: Color = $Background.sample_colors(16)
	var worm = $ViewportContainer/Viewport/SpawnKinematic
	worm.set_dirt_color(color)


func _on_start_button_pressed() -> void:
	$Sounds/PressButton.play()
	change_to_scene(Levels.scene_from_index(Levels.level_idx))
	
