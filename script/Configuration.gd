extends Node

const MASTER_BUS_NAME := "Master"
const UI_BUS_NAME := "UI"
const SFX_BUS_NAME := "SFX"
const MUSIC_BUS_NAME := "Music"

var use_text_animations = true
var master_volume := 100 setget set_master_volume
var ui_volume := 100 setget set_ui_volume
var sfx_volume := 100 setget set_sfx_volume
var music_volume := 100 setget set_music_volume


func set_master_volume(vol: int):
	print("Changing master volume")
	var idx = AudioServer.get_bus_index(MASTER_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	master_volume = vol


func set_ui_volume(vol: int):
	var idx = AudioServer.get_bus_index(UI_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	ui_volume= vol


func set_sfx_volume(vol: int):
	var idx = AudioServer.get_bus_index(SFX_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	sfx_volume = vol


func set_music_volume(vol: int):
	var idx = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	AudioServer.set_bus_volume_db(idx, vol_percent_to_db(vol))
	music_volume = vol


func vol_percent_to_db(vol: int) -> float:
	var frac := vol / 100.0
	return lerp(-60, 0, frac)
