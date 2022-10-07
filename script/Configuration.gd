# Configuration.gd is responsible for storing and saving/loading config
# values at the start and end of the game.

extends Node

const MASTER_BUS_NAME := "Master"
const UI_BUS_NAME := "UI"
const SFX_BUS_NAME := "SFX"
const MUSIC_BUS_NAME := "Music"

var use_text_animations := true
var master_volume := 100 setget set_master_volume
var ui_volume := 100 setget set_ui_volume
var sfx_volume := 100 setget set_sfx_volume
var music_volume := 100 setget set_music_volume


func set_master_volume(vol: int) -> void:
#
# change volume of master bus.
# vol - Volume in percent
#
	print("Changing master volume")
	var idx = AudioServer.get_bus_index(MASTER_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	master_volume = vol


func set_ui_volume(vol: int) -> void:
#
# change volume of UI bus.
# vol - Volume in percent
#
	var idx = AudioServer.get_bus_index(UI_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	ui_volume= vol


func set_sfx_volume(vol: int) -> void:
#
# change volume of master bus.
# vol - Volume in percent
#
	var idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	sfx_volume = vol


func set_music_volume(vol: int) -> void:
#
# change volume of music bus.
# vol - Volume in dB
#
	var idx = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	music_volume = vol


func vol_percent_to_db(vol: int) -> float:
#
# convert volume from percent to db
# vol - Volume in percent
# return - Volume in dB. 0 maps to -60, 100 maps to 0
	var frac := vol / 100.0
	return lerp(-60, 0, frac)
