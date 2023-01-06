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


func sample_colors(samples: int) -> Color:
	var bg: Sprite = $ParallaxLayer/Sprite
	var image: Image = bg.texture.get_data()

	var width := image.get_width()
	var idx_range := width * image.get_height()
	var r_sum := 0.0
	var g_sum := 0.0
	var b_sum := 0.0
	image.lock()
	for _i in range(samples):
		var idx := randi() % idx_range
		var x := int(idx / width)
		var y := int(idx % width)
		var col := image.get_pixel(x, y)
		r_sum += col.r
		g_sum += col.g
		b_sum += col.b
	image.unlock()
	var col := Color(r_sum / samples, g_sum / samples, b_sum / samples, 1.0)
	col.v *= 0.8
	var modulate = $ParallaxLayer/Sprite.modulate
	return Color(col.r * modulate.r, col.g * modulate.g, col.b * modulate.b, col.a * modulate.a)
