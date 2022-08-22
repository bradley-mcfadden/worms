extends TextureRect

var shader = preload("res://scene/partial_fill.tres") 


# Need to create a new ShaderMaterial for each instance, otherwise
# calling "set_shader_param" on the material sets it for every object
# using the shader
func _ready():
	self.material = ShaderMaterial.new()
	self.material.shader = shader
	set_proportion()


func set_proportion(frac: float=1.0):
	self.material.set_shader_param("proportion", frac)
