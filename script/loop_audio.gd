extends AudioStreamPlayer


func _ready():
	var _i = connect("finished", self, "play")
	play()
