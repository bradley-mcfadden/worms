# Configuration.gd is responsible for storing and saving/loading config
# values at the start and end of the game.

extends Node

const CONFIG_FILE_PATH := "user://settings.cfg"
const CONTROL_KEY_TYPE := "key"

var sections := {
	"general" : {
		"use_text_animations" : true,
	},
	"audio" : {
		"master_volume" : 100,
		"ui_volume" : 100,
		"sfx_volume" : 100,
		"music_volume" : 100,
	},
	"graphics" : {
		"fullscreen" : false,
		"borderless" : false,
		"scale_viewport_to_window" : SceneTree.STRETCH_MODE_VIEWPORT,
		"resolution" : {
			"x" : 1024,
			"y" : 600
		},
		"window_size" : {
			"x" : 1024,
			"y" : 600
		},
	},
	"controls" : {
		"current_scheme" : "mouse_keyboard",
		"keyboard" : {
			"ability1" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_J, "shift" : false, "alt" : false, "ctrl" : false},
			"ability2" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_K, "shift" : false, "alt" : false, "ctrl" : false},
			"ability3" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_L, "shift" : false, "alt" : false, "ctrl" : false},
			"ability4" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_SEMICOLON, "shift" : false, "alt" : false, "ctrl" : false},
			"reset" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_R, "shift" : false, "alt" : false, "ctrl" : false},
			"layer_up" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_U, "shift" : false, "alt" : false, "ctrl" : false},
			"layer_down" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_I, "shift" : false, "alt" : false, "ctrl" : false},
			"move_forward" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_W, "shift" : false, "alt" : false, "ctrl" : false},
			"move_left" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_A, "shift" : false, "alt" : false, "ctrl" : false},
			"move_right" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_D, "shift" : false, "alt" : false, "ctrl" : false}, 
			"peek_layer_up" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_U, "shift" : true, "alt" : false, "ctrl" : false},
			"peek_layer_down" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_I, "shift" : true, "alt" : false, "ctrl" : false},
			"lay_eggs" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_T, "shift" : false, "alt" : false, "ctrl" : false},
			"look_ahead" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_N, "shift": false, "alt" : false, "ctrl" : false}
		},
		"mouse_keyboard" : {
			"ability1" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_F, "shift" : false, "alt" : false, "ctrl" : false},
			"ability2" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_D, "shift" : false, "alt" : false, "ctrl" : false},
			"ability3" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_S, "shift" : false, "alt" : false, "ctrl" : false},
			"ability4" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_A, "shift" : false, "alt" : false, "ctrl" : false},
			"reset" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_R, "shift" : false, "alt" : false, "ctrl" : false},
			"layer_up" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_C, "shift" : false, "alt" : false, "ctrl" : false},
			"layer_down" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_V, "shift" : false, "alt" : false, "ctrl" : false},
			"move_forward" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_SPACE, "shift" : false, "alt" : false, "ctrl" : false},
			"move_left" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_F1, "shift" : false, "alt" : false, "ctrl" : false},
			"move_right" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_F2, "shift" : false, "alt" : false, "ctrl" : false}, 
			"peek_layer_up" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_C, "shift" : true, "alt" : false, "ctrl" : false},
			"peek_layer_down" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_V, "shift" : true, "alt" : false, "ctrl" : false},
			"lay_eggs" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_E, "shift" : false, "alt" : false, "ctrl" : false},
			"look_ahead" : {"type" : CONTROL_KEY_TYPE, "scancode" : KEY_W, "shift" : false, "alt" : false, "ctrl" : false}
		}
	}
}


func _enter_tree() -> void:
	cload()


func _exit_tree() -> void:
	save()


func save() -> void:
# 
# save current configuration to filesystem.
#
	var file: ConfigFile = ConfigFile.new()
	for section in sections.keys():
		var sdict: Dictionary = sections[section]
		for param in sections[section].keys():
			file.set_value(section, param, sdict[param])

	var _err: int = file.save(CONFIG_FILE_PATH)


func cload() -> void:
#
# cload
# load configuration, or use default values.
# 
	var file: ConfigFile = ConfigFile.new()
	var _err: int = file.load(CONFIG_FILE_PATH)
	for section in sections.keys():
		var sdict: Dictionary = sections[section]
		for param in sdict.keys():
			sdict[param] = file.get_value(section, param, sdict[param])
