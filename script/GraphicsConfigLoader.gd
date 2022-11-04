#
# GraphicsConfigLoader
# Responsible for applying the Configuration values from Configuration.sections["graphics"].
#

extends Node


var gconfig: Dictionary


func _enter_tree() -> void:
	gconfig = Configuration.sections["graphics"]
	apply_fullscreen()
	apply_borderless()
	apply_scale_viewport_to_window()
	apply_resolution()
	apply_window_size()


func apply_fullscreen() -> void:
	OS.window_fullscreen = gconfig["fullscreen"]


func apply_borderless() -> void:
	OS.window_borderless = gconfig["borderless"]


func apply_scale_viewport_to_window() -> void:
	var stretch_mode: int = gconfig["scale_viewport_to_window"]
	var stretch_aspect: int = SceneTree.STRETCH_ASPECT_KEEP
	var resolution: Vector2 = Vector2(
		Configuration.sections["graphics"]["resolution"]["x"],
		Configuration.sections["graphics"]["resolution"]["y"]
	)
	get_tree().set_screen_stretch(stretch_mode, stretch_aspect, resolution)


func apply_resolution() -> void:
	var stretch_mode: int = gconfig["scale_viewport_to_window"]
	var stretch_aspect: int = SceneTree.STRETCH_ASPECT_KEEP
	var x: int = gconfig["resolution"]["x"]
	var y: int = gconfig["resolution"]["y"]
	get_tree().set_screen_stretch(stretch_mode, stretch_aspect, Vector2(x, y))
	
	var viewport: Viewport = get_viewport()
	viewport.global_canvas_transform = viewport.global_canvas_transform.scaled(Vector2(x / 1024.0, y / 600.0))
	


func apply_window_size() -> void:
	OS.window_size = Vector2(
		gconfig["window_size"]["x"], 
		gconfig["window_size"]["y"]
	)

func get_current_camera_2d() -> Camera2D:
	#
	# get_current_camera_2d returns the current active camera.
	# returns - Current active camera in scene.
	#
		var viewport = get_viewport()
		if not viewport:
			return null
		var cameras_group_name = "__cameras_%d" % viewport.get_viewport_rid().get_id()
		var cameras = get_tree().get_nodes_in_group(cameras_group_name)
		for camera in cameras:
			if camera is Camera2D and camera.current:
				return camera
		return null
