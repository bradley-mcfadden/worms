extends Node2D


func _ready():
	$DepthManager.add_items($Players.get_players())
	$DepthManager.add_items($Enemies.get_enemies())
	$DepthManager.add_items($Obstacles.get_obstacles())
	$DepthManager.add_items($Decorations.get_decorations())
	$DepthManager.set_current_layer(0)


func _input(event):
	if Input.is_action_just_released("reset"):
		reset()


func _process(_delta):
	update()


func get_players() -> Array:
	return $Players.get_players()


func attach_bullet(bullet):
	add_child(bullet)
	bullet.connect("bullet_destroyed", self, "_on_bullet_destroyed")
	$DepthManager.add(bullet.get_layer(), bullet)


func reset():
	$Enemies.reset_all_enemies()
	$Players.reset_all_players()


func _on_all_enemies_dead():
	pass # Replace with function body.


func _on_all_players_dead():
	pass # Replace with function body.


func _on_bullet_destroyed(bullet):
	$DepthManager.remove(bullet)
