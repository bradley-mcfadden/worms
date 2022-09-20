extends Node

signal all_players_dead


func reset_all_players():
	for child in get_players():
		child.reset()


func get_alive_players() -> int:
	var alive = 0
	for child in get_players():
		if child.is_alive():
			alive += 1
	return alive


func get_players() -> Array:
	var players := []
	for child in get_children():
		if child.has_method("get_entity_positions"):
			players.append(child)
			# print(players)
	return players


func _on_Player_died(killer, _overkill):
	print("Player was killed by " + str(killer))
	# remove_child(node)
	# node.queue_free()
	if get_alive_players() == 0:
		print("All players are dead")
		emit_signal("all_players_dead")
