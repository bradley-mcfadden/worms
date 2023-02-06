#
# settings_graphics.gd
# Submenu of settings that handles graphics settings.
#

extends SettingsScrollContainer


func _ready() -> void:
	_init_values()
	_init_connections()


func _init_values() -> void:
	var gconfig: Dictionary = Configuration.sections.graphics
	$Cols/R/Borderless.pressed = gconfig.borderless
	$Cols/R/Fullscreen.pressed = gconfig.fullscreen
	$Cols/R/ScaleViewportToWindow.pressed = gconfig.scale_viewport_to_window
	$Cols/R/UiScale.value = int(gconfig.ui_scale * 100)

	var resolution: OptionButton = $Cols/R/Resolution
	var res_str := "%sx%s" % [gconfig.resolution.x, gconfig.resolution.y]

	for idx in range(resolution.get_item_count()):
		if resolution.get_item_text(idx) == res_str:
			resolution.select(idx)
			break
	var window_size: OptionButton = $Cols/R/WindowSize
	var win_str := "%sx%s" % [gconfig.window_size.x, gconfig.window_size.y]
	for idx in range(window_size.get_item_count()):
		if window_size.get_item_text(idx) == win_str:
			window_size.select(idx)
			break


func _init_connections() -> void:
	var buttons := [
		$Cols/R/Borderless,
		$Cols/R/Fullscreen,
		$Cols/R/ScaleViewportToWindow,
		$Cols/R/Resolution,
		$Cols/R/WindowSize,
		$Cols/R/Vsync,
		$Cols/R/RestoreDefaults
	]
	for btn in buttons:
		btn.connect("focus_entered", self, "_on_control_focus_entered")
		btn.connect("focus_exited", self, "_on_control_focus_exited")
		btn.connect("pressed", self, "_on_button_pressed")

	var checkboxes := [
		$Cols/R/Borderless,
		$Cols/R/Fullscreen,
		$Cols/R/ScaleViewportToWindow,
		$Cols/R/Vsync
	]
	for btn in checkboxes:
		btn.connect("toggled", self, "_on_button_toggled")

	var option_btns := [
		$Cols/R/Resolution,
		$Cols/R/WindowSize
	]
	for btn in option_btns:
		btn.connect("item_focused", self, "_on_control_focus_entered")


func _on_ScaleViewportToWindow_toggled(button_pressed: bool) -> void:
	var stretch_mode: int = SceneTree.STRETCH_MODE_2D if button_pressed else SceneTree.STRETCH_MODE_VIEWPORT
	Configuration.sections.graphics.scale_viewport_to_window = stretch_mode
	GraphicsConfigLoader.apply_scale_viewport_to_window()


func _on_Fullscreen_toggled(button_pressed: bool) -> void:
	Configuration.sections.graphics.fullscreen = button_pressed
	GraphicsConfigLoader.apply_fullscreen()


func _on_Borderless_toggled(button_pressed: bool) -> void:
	Configuration.sections.graphics.borderless = button_pressed
	GraphicsConfigLoader.apply_borderless()


func _on_WindowSize_item_selected(index: int) -> void:
	emit_signal("button_enabled")
	var text: String = $Cols/R/WindowSize.get_item_text(index)
	var tokens := text.split("x")
	var x := int(tokens[0])
	var y := int(tokens[1])
	var gconfig: Dictionary = Configuration.sections.graphics
	gconfig.window_size.x = x
	gconfig.window_size.y = y
	GraphicsConfigLoader.apply_window_size()


func _on_Resolution_item_selected(index: int) -> void:
	emit_signal("button_enabled")
	var text: String = $Cols/R/Resolution.get_item_text(index)
	var tokens := text.split("x")
	var x := int(tokens[0])
	var y := int(tokens[1])
	var gconfig: Dictionary = Configuration.sections.graphics
	gconfig.resolution.x = x
	gconfig.resolution.y = y
	# GraphicsConfigLoader.apply_resolution()


func _on_Vsync_toggled(state: bool) -> void:
	var gconfig: Dictionary = Configuration.sections.graphics
	gconfig.vsync = state
	GraphicsConfigLoader.apply_vsync()


func _on_RestoreDefaults_pressed() -> void:
	GraphicsConfigLoader.reset()
	_init_values()


func _on_UiScale_value_changed(value: float) -> void:
	emit_signal("slider_handle_moved")
	Configuration.sections.graphics.ui_scale = value * 0.01
	GraphicsConfigLoader.apply_ui_scale()
