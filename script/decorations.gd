#
# decorations.gd
#
# Helper script to easily get all valid decorations below the current
# node.
#

extends Node


func get_decorations() -> Array:
# get_decorations
# return All children that are decorations and should be hidden.
	var obs := []
	for child in get_children():
		if child.has_method("get_layer"):
			obs.append(child)

	return obs
