#
# get_obstacles.gd
# Script making it easier to interact with the list of obstacles in a level.
# 
extends Node


func get_obstacles() -> Array:
# get_obstacles
# return - All obstacle children of this node.
	var obs := []
	for child in get_children():
		if child.has_method("get_layer"):
			obs.append(child)

	return obs


func reset() -> void:
	for child in get_children():
		if child.has_method("reset"):
			child.reset()
