extends AudioStreamPlayer

export(float) var normal_pitch = 1.0
export(float) var faster_pitch = 1.1


func _ready():
	var _i = connect("finished", self, "play")


func _on_health_state_changed(is_low: bool):
	if is_low: pitch_scale = faster_pitch
	else: pitch_scale = normal_pitch
		
