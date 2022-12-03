#
# enemies.gd
# Helper script for applying operations to each enemy in a level.
#

extends Node


# Emitted when every enemy in a level is dead.
signal all_enemies_dead


var paths: Node 


func _ready():
	for enemy in get_children():
		enemy.connect("died", self, "_on_Enemy_died")


func reset_all_enemies() -> void:
#
# reset_all_enemies
# Reset each enemy in a level to its starting state.
#
	for child in get_children():
		if child.has_method("take_damage"):
			child.reset()


func get_alive_enemies() -> int:
#
# get_alive_enemies
# return - Number of alive enemies remaining in level.
#
	var num_alive = 0
	for child in get_children():
		if child.has_method("take_damage") and child.is_alive():
			num_alive += 1
	return num_alive


func get_enemies() -> Array:
#
# get_enemies
# return - An array of all enemies in the level.
#
	var enemies := []
	for child in get_children():
		enemies.append(child)

	return enemies


func get_players() -> Array:
# 
# get_players
# return - Get an array of all the players in the level.
#
	return get_parent().get_players()


func get_path_at_layer(layer: int) -> PathGraph:
	for path in paths.get_children():
		if path.layer == layer:
			return path
	return null


func _on_Enemy_died(node: Node, _from: Node, _overkill: bool) -> void:
	print("Enemy " + str(node) + " has died")
	# add a corpse or something
	if get_alive_enemies() == 0:
		emit_signal("all_enemies_dead")
