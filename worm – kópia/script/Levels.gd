extends Node

# This file contains methods for working with the levels directory
# Including saving progress, getting level resources, as well as the 
# next level available.

const LEVELS_PATH = "res://levels"
const IMAGE_SUFFIX = "splash.png"
const SCENE_SUFFIX = "game.tscn"
const CONFIG_SUFFIX = "config.ini"
const PROPERTIES_KEY = "properties"
const PREVIOUS_KEY = "previous"

var level_list: Array = null setget ,get_level_list
var level_idx: int = -1


# get_level_list returns all levels as a list of partial strings
# to get the full level, append with LEVELS_PATH + '/' + string
func get_level_list() -> Array:
    var level_dir = Directory.new()
    if not level_dir.dir_exists(LEVELS_PATH):
        # signal error
        pass
    if not level_dir.open(LEVELS_PATH) == OK:
        # signal error
        pass
    var level_list = []
    level_dir.list_dir_begin(true, true)
    var next = level_dir.get_next()
    while (next != ""):
        level_list.append(next)
        next = level_dir.get_next()
    return level_list


# next_index of level iterator
# increments the index by 1
# the index wraps at the bounds
func next_index() -> int:
    var n = len(level_list)
    if n == 0: return -1
    level_idx = (level_idx + 1) % n
    return level_idx


# set index back to start value
func reset_index() -> int:
    level_idx = -1


# image_from_index returns the path to the splash for a particular
# level index
func image_from_index(idx: int) -> String:
    return "%s/level%d/%s" % [LEVELS_PATH, idx, IMAGE_SUFFIX]


# scene_from_index returns the path to the scene for a level index
func scene_from_index(idx: int) -> String:
    return "%s/level%d/%s" % [LEVELS_PATH, idx, SCENE_SUFFIX]


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
func config_from_index(idx: int) -> Dictionary:
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
        for key in config.get_section_keys(section, key):
            var temp = get_value(section, key)
            section_dict[key] = temp
        
        dict[section] = section_dict
    
    if not dict.has(PROPERTIES_KEY): return {}
    if not dict.has(PREVIOUS_KEY): return {}

    return dict


# config_to_index saves the given configuration to the levels at index
func config_to_index(idx: int, dict:Dictionary) -> bool:
    var path = "%s/level%d/%s" % [LEVELS_PATH, idx, CONFIG_SUFFIX]
    var config = ConfigFile.new()
    
    for section in dict.keys():
        var section_dict = dict[section]
        for key in sections.keys():
            var value = section_dict[key]
            config.set_value(section, key, value)

    return config.save() == OK