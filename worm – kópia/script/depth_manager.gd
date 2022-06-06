# DepthManager allows for grouping nodes into layers.
# One layer at a time is considered active, and the others inactive.
# This should work with DepthController to make shapes that would normally
# collide slide past each other and make invisible all but the current layer.
extends Node

export (int) var collision_offset = 4

onready var layers := []
onready var current_layer := 0

func _ready():
	layers.append([])


# Add an item to the specified layer.
func add(layer:int, item:Node):
	if not item.has_method("get_depth_controller"): return
	while len(layers) <= layer: layers.append([])
	var dc = item.get_depth_controller()
	layers[layer].add(dc)
	dc.set_layer(layer)
	dc.set_active(layer != current_layer)


# Switch the position of item to the layer `to`.
# Cause item to become active or inactive depending on whether the new layer is
# active.
func switch(to:int, item:Node):
	if not item.has_method("get_depth_controller"): return
	var dc = item.get_depth_controller()
	layers[item.get_layer()].remove(dc)
	layers[to].add(dc)
	dc.set_layer(to)
	dc.set_active(to != current_layer)


# Remove an item from the layers
func remove(item:Node):
	if not item.has_method("get_depth_controller"): return
	var dc = item.get_depth_controller()
	layers[item.get_layer()].remove(dc)


# Switch the active layer. All elements in old layer are inactive.
# All elements in new_layer are active.
func set_current_layer(new_layer:int):
	if new_layer == current_layer: return
	for item in layers[current_layer]: item.set_active(false)
	for item in layers[new_layer]: item.set_active(true)
	current_layer = new_layer
