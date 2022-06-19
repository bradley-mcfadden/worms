extends Node

signal all_players_dead()


func get_players() -> Array:
	var players := []
	for child in get_children():
		if child.has_method("get_entity_positions"):
			players.append(child)
	return players


func _on_Player_died(node, _killer, _overkill):
	node.queue_free()
	if get_child_count() == 0:
		emit_signal("all_players_dead")
