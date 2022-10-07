# worm_cam is used to track the worm, and zoom enough to fit it on the sreen.

extends Camera2D


func zoom_to(new_zoom: Vector2) -> void:
#
# zoom_to smoothly interpolates the camera zoom over 2 secs to the
# new level.
# new_zoom - New camera zoom to transition to.
#

	$Tween.interpolate_property(
		self, "zoom", self.zoom, new_zoom, 2.0
	)
	if $Tween.is_inside_tree():
		$Tween.start()
