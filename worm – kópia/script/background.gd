extends Sprite

export var scroll_speed := Vector2(1.0, 1.0)

var last_tracked_position := Vector2(0, 0)
var max_tracked_speed := Vector2(1, 1)


func _ready():
	pass


func update_tracked_position(new_position: Vector2):
	var mag: Vector2 = (new_position - last_tracked_position) / max_tracked_speed
	last_tracked_position = new_position
	self.material.set_shader_param("scroll_speed", mag)
