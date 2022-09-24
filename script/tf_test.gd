extends Node2D

var death_screen
var enemies_dead_screen
var primary_player


func _ready():
	$Music.play()
	$DepthManager.add_items($Players.get_players())
	$DepthManager.add_items($Enemies.get_enemies())
	$DepthManager.add_items($Obstacles.get_obstacles())
	$DepthManager.add_items($Decorations.get_decorations())
	$DepthManager.set_current_layer(0)
	$NoiseManager.listeners.append_array($Enemies.get_enemies())
	$Background.set_layer(0)
	$CanvasLayer/DepthGauge.change_depth(0)
	death_screen = $CanvasLayer/DeathScreen
	enemies_dead_screen = $CanvasLayer/AllEnemiesDead
	primary_player = $Players/SpawnKinematic
	primary_player.background = $Background


func _input(_event):
	pass
	# if Input.is_action_just_released("reset"):
	# 	reset()


func _process(_delta):
	update()


func get_players() -> Array:
	return $Players.get_players()


func attach_bullet(bullet):
	add_child(bullet)
	bullet.connect("bullet_destroyed", self, "_on_bullet_destroyed")
	$DepthManager.add(bullet.get_layer(), bullet)


func reset():
	death_screen.visible = false
	enemies_dead_screen.visible = false
	$Enemies.reset_all_enemies()
	$Players.reset_all_players()
	$Music.play()


func to_main_menu():
	pass


func quit_to_desktop():
	pass


func get_current_camera_2d():
	var viewport = get_viewport()
	if not viewport:
		return null
	var cameras_group_name = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(cameras_group_name)
	for camera in cameras:
		if camera is Camera2D and camera.current:
			return camera
	return null


func _on_lay_eggs():
	# in future, probably play an animation and wait for it finish before that
	Levels.next_level_or_main(get_tree())
	$LayEggs.play()


func _on_all_enemies_dead():
	# var camera = get_current_camera_2d()
	# var screen_parent = enemies_dead_screen.get_parent()
	# if screen_parent != camera:
	# 	enemies_dead_screen.get_parent().remove_child(enemies_dead_screen)
	# 	camera.add_child(enemies_dead_screen)
	enemies_dead_screen.visible = true
	enemies_dead_screen.fade_in()


func _on_all_players_dead():
	# var camera = get_current_camera_2d()
	# if death_screen.get_parent() != camera:
	# 	death_screen.get_parent().remove_child(death_screen)
	# 	camera.add_child(death_screen)
	death_screen.visible = true
	death_screen.fade_in()


func _on_bullet_destroyed(bullet):
	$DepthManager.remove(bullet)


func _on_restart():
	reset()
