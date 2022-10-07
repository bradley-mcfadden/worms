#
# players.gd
# Script to simplify working with a large list of players in a level.
# 
extends Node

# Emitted when everything considered a player has died.
signal all_players_dead


func reset_all_players() -> void:
#
# reset_all_players
# Call reset for all players, changing them back to initial state.
#
	for child in get_players():
		child.reset()


func get_alive_players() -> int:
#
# get_alive_players
# return - Number of alive players
#
	var alive = 0
	for child in get_players():
		if child.is_alive():
			alive += 1
	return alive


func get_players() -> Array:
#
# get_players
# return - All players as an array
#
	var players := []
	for child in get_children():
		if child.has_method("get_entity_positions"):
			players.append(child)
	return players


func _on_Player_died(killer: Node, _overkill: bool) -> void:
	print("Player was killed by " + str(killer))
	if get_alive_players() == 0:
		print("All players are dead")
		emit_signal("all_players_dead")
