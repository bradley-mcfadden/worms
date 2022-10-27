# background_noise.gd sets noise offset, color and layer parameters
# for a ShaderMaterial.

extends ParallaxBackground

class_name BackgroundNoise

export(Color) var color := Color("#756b4b")

var noise_texture: Texture
var material: ShaderMaterial


func _ready() -> void:
	noise_texture = $ParallaxLayer/Sprite.texture
	material = $ParallaxLayer/Sprite.material
	set_color(color)


func set_noise_offset(offset: Vector2) -> void:
	material.set_shader_param("offset", offset)


func set_layer(layer: int) -> void:
	material.set_shader_param("layer", layer)


func set_color(c: Color) -> void:
	color = c
	var col_v = Vector3(color.r, color.g, color.b)
	material.set_shader_param("color", col_v)


func _on_layer_changed(to: int) -> void:
	call_deferred("set_layer", to)
