#
# interactibles.gd
# Convenience class for getting interactibles (powerups, hittable non-enemies)
# and or performing operations on them.
#

extends Node


func get_interactibles() -> Array:
#
# get_interactibles
# Return each interactble child of the node.
#
	var arr := []
	for child in get_children():
		if child.has_method("get_layer"):
			arr.append(child)
	return arr


func reset() -> void:
#
# reset
# Call reset() method for each child.
#
	for child in get_children():
		if child.has_method("reset"):
			child.reset()
