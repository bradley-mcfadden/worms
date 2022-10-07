# bg_music.gd
# Script that makes the background music loop, and reacts to the player
# turning low health by slightly increasing the playback speed of the music.
#
extends AudioStreamPlayer

export(float) var normal_pitch := 1.0
export(float) var faster_pitch := 1.1


func _ready() -> void:
	var _i = connect("finished", self, "play")


func _on_health_state_changed(is_low: bool) -> void:
	if is_low: pitch_scale = faster_pitch
	else: pitch_scale = normal_pitch
		
