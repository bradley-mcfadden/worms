#
# settings_audio.gd
# Submenu of settings that handles audio settings.
#

extends SettingsScrollContainer


func _ready() -> void:
	_init_values()
	_init_connections()


func _init_values() -> void:
	$Cols/R/MasterVolumeSlider.value = float(Configuration.sections["audio"]["master_volume"])
	$Cols/R/SoundFXVolumeSlider.value = float(Configuration.sections["audio"]["sfx_volume"])
	$Cols/R/UISoundVolumeSlider.value = float(Configuration.sections["audio"]["ui_volume"])
	$Cols/R/MusicVolumeSlider.value = float(Configuration.sections["audio"]["music_volume"])


func _init_connections() -> void:
	var sliders: Array = [
		$Cols/R/MasterVolumeSlider, 
		$Cols/R/SoundFXVolumeSlider,
		$Cols/R/UISoundVolumeSlider,
		$Cols/R/MusicVolumeSlider
	]

	for slider in sliders:
		slider.connect("value_changed", self, "_on_slider_handle_moved")
		slider.connect("focus_entered", self, "_on_control_focus_entered")
		slider.connect("focus_exited", self, "_on_control_focus_exited")


func _on_master_vol_drag_ended(changed: bool) -> void:
	if not changed: return
	var volume: float = $Cols/R/MasterVolumeSlider.value
	Configuration.set_master_volume(volume)
	AudioConfigLoader.apply_master_volume()


func _on_sfx_vol_drag_ended(changed: bool) -> void:
	if not changed: return
	var volume: float = $Cols/R/SoundFXVolumeSlider.value
	Configuration.set_sfx_volume(volume)
	AudioConfigLoader.apply_sfx_volume()


func _on_ui_vol_drag_ended(changed: bool) -> void:
	if not changed: return
	var volume: float = $Cols/R/UISoundVolumeSlider.value
	Configuration.set_ui_volume(volume)
	AudioConfigLoader.apply_ui_volume()


func _on_music_vol_drag_ended(changed: bool) -> void:
	if not changed: return
	var volume: float = $Cols/R/MusicVolumeSlider.value
	Configuration.set_music_volume(volume)
	AudioConfigLoader.apply_music_volume()
