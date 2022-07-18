extends Node2D


var death_screen
var primary_player

func _ready():
	$DepthManager.add_items($Players.get_players())
	$DepthManager.add_items($Enemies.get_enemies())
	$DepthManager.add_items($Obstacles.get_obstacles())
	$DepthManager.add_items($Decorations.get_decorations())
	$DepthManager.set_current_layer(0)
	death_screen = $DeathScreen
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
	$Enemies.reset_all_enemies()
	$Players.reset_all_players()


func get_current_camera2D():
	var viewport = get_viewport()
	if not viewport:
		return null
	var camerasGroupName = "__cameras_%d" % viewport.get_viewport_rid().get_id()
	var cameras = get_tree().get_nodes_in_group(camerasGroupName)
	for camera in cameras:
		if camera is Camera2D and camera.current:
			return camera
	return null


func _on_all_enemies_dead():
	pass # Replace with function body.


func _on_all_players_dead():
	var camera = get_current_camera2D()
	if death_screen.get_parent() != camera:
		death_screen.get_parent().remove_child(death_screen)
		camera.add_child(death_screen)
	death_screen.visible = true
	death_screen.fade_in()


func _on_bullet_destroyed(bullet):
	$DepthManager.remove(bullet)


func _on_restart():
	reset()
