# Levels.gd contains methods for working with the levels directory
# Including saving progress, getting level resources, as well as the
# next level available.
extends Node

# This file contains methods for working with the levels directory
# Including saving progress, getting level resources, as well as the
# next level available.

const LEVELS_PATH := "res://levels"
const IMAGE_SUFFIX := "splash.jpg"
const SCENE_SUFFIX := "game.tscn"
const CONFIG_SUFFIX := "config.ini"
const PROPERTIES_KEY := "properties"
const PREVIOUS_KEY := "previous"

onready var loading_path: String = ""
var level_list: Array = get_level_list() setget , get_level_list
var level_idx: int = -1


func get_level_list() -> Array:
# get_level_list returns all levels as a list of partial strings
# to get the full level, append with LEVELS_PATH + '/' + string
	var level_dir = Directory.new()
	if not level_dir.dir_exists(LEVELS_PATH):
		# signal error
		print("Directory does not exist")
	if not level_dir.open(LEVELS_PATH) == OK:
		# signal error
		print("Could not open level directory")
	level_list = []
	level_dir.list_dir_begin(true, true)
	var next = level_dir.get_next()
	while next != "":
		level_list.append(next)
		next = level_dir.get_next()
	return level_list


func next_index(wrap: bool = false) -> int:
# next_index of level iterator
# increments the index by 1
# the index wraps at the bounds
# return - Next level index
	var n = len(level_list)
	if n == 0:
		return -1
	if not wrap:
		level_idx += 1
		if level_idx >= n:
			level_idx = -1
	else:
		level_idx = (level_idx + 1) % n
	return level_idx


func reset_index() -> void:
# set index back to start value
	level_idx = -1


func image_from_index(idx: int) -> String:
# image_from_index returns the path to the splash for a particular
# idx - level index
# return - path to image
	return "%s/level%d/%s" % [LEVELS_PATH, idx, IMAGE_SUFFIX]


func scene_from_index(idx: int) -> String:
# scene_from_index returns the path to the scene for a level index
# idx - Index of level
# return - Path to scene
	return "%s/level%d/%s" % [LEVELS_PATH, idx, SCENE_SUFFIX]


func config_from_index(idx: int) -> Dictionary:
# config_from_index returns a dictionary with config info for a level index
# [properties]
# completed: int
# name: String
# nenemies: int
# ncollectibles: int
# [previous]
# score: int
# nslain: int
# ncollected: int
# return - Dictionary of the above info
	var path = "%s/level%d/%s" % [LEVELS_PATH, idx, CONFIG_SUFFIX]
	var config = ConfigFile.new()
	var err = config.load(path)
	var dict = {}
	if err != OK:
		return {}

	# TODO: Make this more efficient if the number of sections is
	# known
	for section in config.get_sections():
		var section_dict = {}
		for key in config.get_section_keys(section):
			var temp = config.get_value(section, key)
			section_dict[key] = temp

		dict[section] = section_dict

	if not dict.has(PROPERTIES_KEY):
		return {}
	if not dict.has(PREVIOUS_KEY):
		return {}

	return dict


func config_to_index(idx: int, dict: Dictionary) -> bool:
# config_to_index saves the given configuration to the levels at index
# idx - Index to save config at
# dict - Configuration values to save
	var path = "%s/level%d/%s" % [LEVELS_PATH, idx, CONFIG_SUFFIX]
	var config = ConfigFile.new()

	for section in dict.keys():
		var section_dict = dict[section]
		for key in section_dict.keys():
			var value = section_dict[key]
			config.set_value(section, key, value)

	return config.save(path) == OK


func next_level_or_main() -> void:
# next_level_or_main will load the next level without wrapping
# if the index would wrap, instead return to main menu
	print("Changing levels %d" % level_idx)
	var idx = next_index(false)
	print("Changing levels %d" % idx)
	var scene: String
	if idx == -1:
		# Change resolution to 1024x600 but don't save it
		GraphicsConfigLoader.use_default_resolution()
		scene = "res://scene/TitleScreen.tscn"
	else:
		GraphicsConfigLoader.apply_resolution()
		scene = Levels.scene_from_index(idx)
	AsyncLoader.load_resource(scene)
	loading_path = scene
	var _r = AsyncLoader.connect("resource_loaded", self, "_on_resource_loaded")


func _on_resource_loaded(path: String, resource: Resource) -> void:
	if path == loading_path:
		AsyncLoader.call_deferred("change_scene_to", resource)
		AsyncLoader.disconnect("resource_loaded", self, "_on_resource_loaded")
		loading_path = ""
