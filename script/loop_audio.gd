#
# loop_audio.gd
# Attach this script to an AudioStreamPlayer you want
# to continously loop.

extends AudioStreamPlayer


func _ready() -> void:
	var _i = connect("finished", self, "play")
	play()
