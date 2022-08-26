extends TextureRect


func _ready():
	for prop in texture.get_property_list():
		print(prop)
	print(texture)
	print(texture.as_normalmap)
	print(texture.bump_strength)
	print(texture.flags)
	print(texture.height)
	print(texture.width)
	print(texture.seamless)
	print(texture.noise)
	print(texture.noise.offset)
	print(texture.noise_offset)


func _process(_delta):
	# print(texture.get_property_list())
	pass
