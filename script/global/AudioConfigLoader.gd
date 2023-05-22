#
# AudioConfigLoader
# Responsible for applying saved Configuration values from Configuration.sections["audio"].
#

extends Node

const MASTER_BUS_NAME := "Master"
const UI_BUS_NAME := "UI"
const SFX_BUS_NAME := "SFX"
const MUSIC_BUS_NAME := "Music"

var aconfig: Dictionary


func _enter_tree() -> void:
	aconfig = Configuration.sections["audio"]
	apply_master_volume()
	apply_ui_volume()
	apply_sfx_volume()
	apply_music_volume()


func apply_master_volume() -> void:
	var idx: int = AudioServer.get_bus_index(MASTER_BUS_NAME)
	var vol: float = vol_percent_to_db(aconfig["master_volume"])
	AudioServer.set_bus_volume_db(idx, vol)


func apply_ui_volume() -> void:
	var idx: int = AudioServer.get_bus_index(UI_BUS_NAME)
	var vol: float = vol_percent_to_db(aconfig["ui_volume"])
	AudioServer.set_bus_volume_db(idx, vol)


func apply_sfx_volume() -> void:
	var idx: int = AudioServer.get_bus_index(SFX_BUS_NAME)
	var vol: float = vol_percent_to_db(aconfig["sfx_volume"])
	AudioServer.set_bus_volume_db(idx, vol)


func apply_music_volume() -> void:
	var idx: int = AudioServer.get_bus_index(MUSIC_BUS_NAME)
	var frac: float = aconfig.music_volume
	print("Setting music volume to ", frac)
	var vol: float = vol_percent_to_db(frac)
	AudioServer.set_bus_volume_db(idx, vol)


func vol_percent_to_db(vol: int) -> float:
#
# convert volume from percent to db
# vol - Volume in percent
# return - Volume in dB. 0 maps to -60, 100 maps to 0
		var frac := vol / 100.0
		return lerp(-60, 0, frac)
