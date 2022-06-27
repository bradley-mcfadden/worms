extends Node


func get_obstacles() -> Array:
	var obs := []
	for child in get_children():
		if child.has_method("get_layer"):
			obs.append(child)
	
	return obs
