extends Camera2D


func zoom_to(new_zoom: Vector2):
	$Tween.interpolate_property(
		self, "zoom", self.zoom, new_zoom, 2.0
	)
	# print("zoom ", zoom, " new zoom ", new_zoom)
	if $Tween.is_inside_tree():
		$Tween.start()
