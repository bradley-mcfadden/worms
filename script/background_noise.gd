extends ParallaxBackground

export(Color) var color := Color("#756b4b")

var noise_texture
var material


func _ready():
	noise_texture = $ParallaxLayer/Sprite.texture
	material = $ParallaxLayer/Sprite.material
	set_color(color)


func set_noise_offset(offset):
	material.set_shader_param("offset", offset)


func set_layer(layer):
	material.set_shader_param("layer", layer)


func set_color(c: Color):
	color = c
	var col_v = Vector3(color.r, color.g, color.b)
	material.set_shader_param("color", col_v)


func _on_layer_changed(to):
	set_layer(to)
