#
# segment_health.gd
# Individual segment of the health bar.
# Allows a fraction of it to be filled.
#
extends TextureRect

onready var proportion := 1.0
var shader = preload("res://shader/partial_fill.tres")


# Need to create a new ShaderMaterial for each instance, otherwise
# calling "set_shader_param" on the material sets it for every object
# using the shader
func _ready() -> void:
	self.material = ShaderMaterial.new()
	self.material.shader = shader
	set_proportion()


func set_proportion(frac: float = 1.0) -> void:
	self.material.set_shader_param("proportion", frac)
	proportion = frac
