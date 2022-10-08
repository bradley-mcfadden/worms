# Configuration.gd is responsible for storing and saving/loading config
# values at the start and end of the game.

extends Node

const CONFIG_FILE_PATH := "user://settings.cfg"
const MASTER_BUS_NAME := "Master"
const UI_BUS_NAME := "UI"
const SFX_BUS_NAME := "SFX"
const MUSIC_BUS_NAME := "Music"

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
		
	},
}


func _enter_tree() -> void:
	cload()


func _exit_tree() -> void:
	save()


func set_master_volume(vol: int) -> void:
#
# change volume of master bus.
# vol - Volume in percent
#
	print("Changing master volume")
	var idx = AudioServer.get_bus_index(MASTER_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	sections["audio"]["master_volume"] = vol


func set_ui_volume(vol: int) -> void:
#
# change volume of UI bus.
# vol - Volume in percent
#
	var idx = AudioServer.get_bus_index(UI_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	sections["audio"]["ui_volume"] = vol


func set_sfx_volume(vol: int) -> void:
#
# change volume of master bus.
# vol - Volume in percent
#
	var idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	sections["audio"]["sfx_volume"] = vol


func set_music_volume(vol: int) -> void:
#
# change volume of music bus.
# vol - Volume in dB
#
	var idx = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	sections["audio"]["music_volume"] = vol


func vol_percent_to_db(vol: int) -> float:
#
# convert volume from percent to db
# vol - Volume in percent
# return - Volume in dB. 0 maps to -60, 100 maps to 0
	var frac := vol / 100.0
	return lerp(-60, 0, frac)


func save() -> void:
# 
# save current configuration to filesystem.
#
	var file: ConfigFile = ConfigFile.new()
	for section in sections.keys():
		var sdict: Dictionary = sections[section]
		for param in sections[section].keys():
			file.set_value(section, param, sdict[param])

	file.save(CONFIG_FILE_PATH)


func cload() -> void:
#
# cload
# load configuration, or use default values.
# 
	var file: ConfigFile = ConfigFile.new()
	file.load(CONFIG_FILE_PATH)
	for section in sections.keys():
		var sdict: Dictionary = sections[section]
		for param in sdict.keys():
			sdict[param] = file.get_value(section, param, sdict[param])
