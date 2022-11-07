# worm_cam is used to track the worm, and zoom enough to fit it on the sreen.

extends Camera2D


func _ready():
	var gconfig: Dictionary = Configuration.sections["graphics"]
	var res := Vector2(
		gconfig["resolution"]["x"],
		gconfig["resolution"]["y"]
	)
	if res.x == 1024 and res.y == 600:
		offset.x = 0
		offset.y = 0
	elif res.x == 1920 and res.y == 1080:
		offset.x = 1460
		offset.y = 720
	elif res.x == 1280 and res.y == 720:
		offset.x = 480
		offset.y = 240
	elif res.x == 720 and res.y == 480:
		offset.x = -360
		offset.y = -240
	elif res.x == 480 and res.y == 360:
		offset.x = -720
		offset.y = -480
	elif res.x == 360 and res.y == 240:
		offset.x = -1080
		offset.y = -720
	elif res.x == 160 and res.y == 120:
		offset.x = -1440
		offset.y = -960
	elif res.x == 80 and res.y == 60:
		offset.x = -1440
		offset.y = -960
	else:
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
