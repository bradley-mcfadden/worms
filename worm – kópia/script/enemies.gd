extends Node

signal all_enemies_dead()


func reset_all_enemies():
	for child in get_children():
		if child.has_method("take_damage"):
			child.reset()


func get_alive_enemies() -> int:
	var num_alive = 0
	for child in get_children():
		if child.has_method("take_damage") and child.is_alive():
			num_alive += 1
	return num_alive


func get_enemies() -> Array:
	var enemies := []
	for child in get_children():
		enemies.append(child)
	
	return enemies


func get_players() -> Array:
	return get_parent().get_players()


func _on_Enemy_died(node, _from, _overkill):
	print("Enemy " + str(node) + " has died")
	# add a corpse or something
	if get_alive_enemies() == 0:
		emit_signal("all_enemies_dead")
