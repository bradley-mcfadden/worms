#
# ui.gd 
# Responsible for in level UI. This is a CanvasLayer containing
# all in level user interface. It handles connecting its nodes
# to exterior nodes, and providing common operations.
#

extends CanvasLayer


func _ready() -> void:
	var health_bar: Control = $HealthBar
	var a_display: Control = $AbilitiesDisplay
	health_bar.rect_position = Vector2(
		16,
		-16 + 600 - health_bar.rect_size.y
	)
	a_display.rect_position = Vector2(
		-16 - a_display.rect_size.x + 1024, #res.x - a_display.rect_size.x,
		-16 - a_display.rect_size.y + 600
	)


func connect_to_dm(depth_manager: Node) -> void:
#
# connect_to_dm - Connect nodes to DepthManager.
# depth_manager - DepthManager node of level.
#
	var _err := depth_manager.connect(
		"layer_changed", 
		$DepthGauge, 
		"_on_DepthManager_layer_changed"
	)
	_err = depth_manager.connect(
		"number_of_layers_changed", 
		$DepthGauge, 
		"_on_DepthManager_number_of_layers_changed"
	)
	_err = depth_manager.connect(
		"layer_peeked",
		$BlackBars,
		"_on_layer_peeked"
	)
	$DepthGauge.set_maximum_depth(len(depth_manager.layers))
	$DepthGauge.change_depth(depth_manager.current_layer)


func fade_out() -> void:
#
# fade_out - Fade canvas layer to black.
#
	$AllEnemiesDead.visible = false
	$DeathScreen.visible = false
	$Panel.visible = true
	$Tween.interpolate_property($Panel, "modulate", null, Color.black, 2.0)
	$Tween.start()


func fade_in() -> void:
#
# fade_in - Fade from current background color to transparent.
#
	$Panel.visible = true
	$Tween.interpolate_property($Panel, "modulate", null, Color.transparent, 1.0)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Panel.visible = false


func reset() -> void:
#
# reset - Change everything back to how it was initially.
#
	$DeathScreen.visible = false
	$AllEnemiesDead.visible = false
	$Panel.visible = false


func _on_all_players_dead() -> void:
	$DeathScreen.visible = true
	$DeathScreen.fade_in()


func _on_all_enemies_dead() -> void:
	$AllEnemiesDead.visible = true
	$AllEnemiesDead.fade_in()
