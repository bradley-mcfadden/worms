extends TextureRect


func sample_colors(samples: int) -> Color:
	var image: Image = texture.get_data()

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
	return col


func set_noise_offset(offset: Vector2) -> void:
	material.set_shader_param("offset", offset * 0.4)
