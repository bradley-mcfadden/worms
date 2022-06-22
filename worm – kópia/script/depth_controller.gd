# DepthController is meant to be managed by DepthManager
# It allows for automatically hiding a Node2D when it moves to an inactive 
# layer. For nodes with collision, it also will disable it when the layer is
# inactive.
extends Node

export (int) var depth_layer = 0

var start_mask 
var start_layer
var parent:Node2D


func _ready():
	parent = get_parent()
	
	if parent.has_method("set_collision_mask"):
		start_layer = parent.collision_layer
		start_mask = parent.collision_mask
	
		set_collision_layer(start_layer + 4 * depth_layer)
		set_collision_mask(start_mask + 4 * depth_layer)


# Set whether this object is active. An active object is visible and collides,
# inactive objects are not visible and do not collide.
func set_active(is_active:bool):
	for child in parent.get_children():
		if child.has_property("disabled"):
			child.disabled = is_active
	
	parent.set_visible(is_active)


# Change the controlled object's depth layer.
func set_layer(layer:int):
	depth_layer = layer
	
	if parent.has_method("set_collision_mask"):
		set_collision_layer(start_layer + 4 * depth_layer)
		set_collision_mask(start_mask + 4 * depth_layer)


# Set the collision mask to the given layer. Does not allow for multiple masks
# to be set.
func set_collision_mask(layer:int):
	parent.collision_mask = int(pow(2, layer))


# Set the collision layer to the given layer. Does not allow for multiple layers
# to be set.
func set_collision_layer(layer:int):
	parent.collision_layer = int(pow(2, layer)) 


# Reset parent's collision layer and mask to match its initial depth value.
func reset():
	if parent.has_method("set_collision_mask"):
		set_collision_layer(start_layer + 4 * depth_layer)
		set_collision_mask(start_mask + 4 * depth_layer)
		
		depth_layer = start_layer


# Finds the base 2 log for a number.
func log2(val:int) -> int:
	var counter := 0
	var val2 = val
	while (val2 > 1):
		val2 >>= 1
		counter += 1
	return counter
