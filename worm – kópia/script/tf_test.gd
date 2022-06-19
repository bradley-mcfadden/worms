extends Node2D


var target = null


func _input(event):
	if event.is_action_pressed("mouse_lmb"):
		target = get_global_mouse_position()


func _process(_delta):
	update()


func _draw():
	if target == null: return
	draw_line(target+Vector2.DOWN*5, target+Vector2.UP*5, Color.palevioletred)
	draw_line(target+Vector2.LEFT*5, target+Vector2.RIGHT*5, Color.palevioletred)


func get_target() -> Vector2:
	return target


func get_players() -> Array:
	return $Players.get_players()


func attach_bullet(bullet):
	add_child(bullet)


func _on_all_enemies_dead():
	pass # Replace with function body.


func _on_all_players_dead():
	pass # Replace with function body.
