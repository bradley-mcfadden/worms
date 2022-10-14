#
# settings_audio.gd
# Submenu of settings that handles audio settings.
#

extends SettingsScrollContainer


func _on_master_vol_drag_ended(changed: bool) -> void:
	if not changed: return
	var volume = $Menu/Tabs/audio/Cols/R/MasterVolumeSlider.value
	Configuration.set_master_volume(volume)


func _on_sfx_vol_drag_ended(changed: bool) -> void:
	if not changed: return
	var volume = $Menu/Tabs/audio/Cols/R/SoundFXVolumeSlider.value
	Configuration.set_sfx_volume(volume)


func _on_ui_vol_drag_ended(changed: bool) -> void:
	if not changed: return
	var volume = $Menu/Tabs/audio/Cols/R/UISoundVolumeSlider.value
	Configuration.set_ui_volume(volume)


func _on_music_vol_drag_ended(changed: bool) -> void:
	if not changed: return
	var volume = $Menu/Tabs/audio/Cols/R/MusicVolumeSlider.value
	Configuration.set_music_volume(volume)
