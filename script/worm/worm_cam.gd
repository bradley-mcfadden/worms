# worm_cam is used to track the worm, and zoom enough to fit it on the sreen.

extends Camera2D


func _ready():
	var gconfig: Dictionary = Configuration.sections["graphics"]
	var res := Vector2(
		gconfig["resolution"]["x"],
		gconfig["resolution"]["y"]
	)
	# off_x = 1.58 * res.x - 1566
	# off_y = 0.9552 * res.y  - 1025
	offset.x = 1.58 * res.x - 1566.0
	offset.y = 0.9552 * res.y - 1025.0


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
