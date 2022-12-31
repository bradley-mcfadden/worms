#
# skin_select.gd
# Allows player to select their skin and records it to save file.
#

extends Control

const ANIMATION_OPEN_HEADER := "[siny period=2.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_HEADER := "[/siny]"
const ANIMATION_OPEN_MSG := "[siny period=4.0 offset=5.0 animate=1.0]"
const ANIMATION_CLOSE_MSG := "[/siny]"
const LEVEL_SELECT_PATH := "res://scene/LevelSelect.tscn"


var current_skin_idx := 0
var skins: Array = []
var worm: Node2D = null
var egg: TextureRect = null


func _ready() -> void:
	fade_in()
	_init_labels()
	_init_connections()
	# initialize current_skin_idx to saved skin
	skins = Skins.skins()
	worm = $ViewportContainer/Viewport/SpawnKinematic
	worm.background = $Background
	egg = $Skin/EggRow/Spinner
	_load_current_skin()


func _load_next_skin() -> void:
	current_skin_idx = (current_skin_idx + 1) % len(skins)
	_load_current_skin()


func _load_previous_skin() -> void:
	current_skin_idx = int(abs((current_skin_idx - 1) % len(skins)))
	_load_current_skin()


func _load_current_skin() -> void:
	var current_skin: Dictionary = skins[current_skin_idx]
	var skin_name: String = current_skin["name"]

	var skin_material: Material = load(current_skin["material"])
	egg.material = skin_material
	worm.material = skin_material

	if PlayerSave.has_collected(current_skin["id"]):
		print("Player has collected skin %s" % current_skin["id"])
		egg.modulate = Color.white
		worm.modulate = Color.white
		$Skin/InfoRow/Name.text = skin_name
	else:
		print("Player has not collected skin %s" % current_skin["id"])
		egg.modulate = Color.black
		worm.modulate = Color.black
		$Skin/InfoRow/Name.text = "???"


func _init_connections() -> void:
	var next_skin_button := $Skin/EggRow/Next
	var prev_skin_button := $Skin/EggRow/Previous
	var back_button = $Back

	var _ret := next_skin_button.connect("pressed", self, "_on_next_skin_button_pressed")
	_ret = prev_skin_button.connect("pressed", self, "_on_prev_skin_button_pressed")
	_ret = back_button.connect("pressed", self, "_on_back_button_pressed")
	
	# Add handler for focus
	for btn in [next_skin_button, prev_skin_button, back_button]:
		_ret = btn.connect("focus_entered", self, "_on_button_focused")


func _on_button_focused() -> void:
	$Sounds/FocusIn.play()


func _on_next_skin_button_pressed() -> void:
	_load_next_skin()
	$Sounds/NavigateForward.play()


func _on_prev_skin_button_pressed() -> void:
	_load_previous_skin()
	$Sounds/NavigateBackward.play()


func _on_back_button_pressed() -> void:
	# Commit current skin to player's save file if it is unlocked
	var current_skin: Dictionary = skins[current_skin_idx]
	if PlayerSave.has_collected(current_skin["id"]):
		var skin_name: String = current_skin["name"]
		var _ret := PlayerSave.set_current_skin(skin_name)
	
	$Sounds/PressButton.play()
	# Load level select
	var _ret = AsyncLoader.connect("resource_loaded", self, "_on_resource_loaded")
	worm.paused = true
	AsyncLoader.load_resource(LEVEL_SELECT_PATH)


func _on_resource_loaded(_path: String, resource: Resource) -> void:
	AsyncLoader.disconnect("resource_loaded", self, "_on_resource_loaded")
	AsyncLoader.change_scene_to(resource)


func _init_labels() -> void:
	var animate: bool = Configuration.sections["general"]["use_text_animations"]
	var header: RichTextLabel = $Skin/Title
	set_text(header, header.text, ANIMATION_OPEN_HEADER, ANIMATION_CLOSE_HEADER, true, animate)


func fade_in() -> void:
	$Tween.interpolate_property(self, "modulate", Color.black, Color.white, 1.0)
	$Tween.start()
	yield($Tween, "tween_completed")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


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
