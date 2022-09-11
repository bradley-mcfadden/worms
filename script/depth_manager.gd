# DepthManager allows for grouping nodes into layers.
# One layer at a time is considered active, and the others inactive.
# This should work with DepthController to make shapes that would normally
# collide slide past each other and make invisible all but the current layer.
extends Node

signal layer_changed(to)
signal number_of_layers_changed(to)

enum SegmentState { ALIVE, DEAD }

var layers := []
onready var current_layer := 0


func _ready():
	layers.append([])


func add_items(items: Array):
	# print("Add group of items ", items)
	for item in items:
		if item.has_method("get_layer"):
			add(item.get_layer(), item)


# Add an item to the specified layer.
func add(layer: int, item: Node):
	if not item.has_method("get_depth_controllers"):
		return
	# print("Add ", item, " to layer ", layer)
	var prev_len: int = len(layers)
	while len(layers) <= layer:
		layers.append([])
	if prev_len != len(layers):
		emit_signal("number_of_layers_changed", len(layers))

	var controllers = item.get_depth_controllers()
	for dc in controllers:
		layers[layer].append(dc)
		if not dc.is_connected("tree_exited", self, "_on_dc_tree_exited"):
			dc.connect("tree_exited", self, "_on_dc_tree_exited", [layer, dc])
		dc.set_layer(layer)
		dc.set_active(layer == current_layer)


# Switch the position of item to the layer `to`.
# Cause item to become active or inactive depending on whether the new layer is
# active.
func switch(to: int, item: Node):
	if not item.has_method("get_depth_controllers"):
		return
	var controllers = item.get_depth_controllers()
	var item_curr_layer = item.get_layer()
	for dc in controllers:
		var idx = layers[item_curr_layer].find(dc)
		layers[item_curr_layer].remove(idx)
		layers[to].append(dc)
		dc.set_layer(to)
		# print("Changing ", dc.get_parent())
		dc.set_active(to == current_layer)


func switch_if_safe(to: int, item: Node):
	if is_switch_valid(to):
		switch(to, item)
		return true
	return false


# Remove an item from the layers
func remove(item: Node):
	if not item.has_method("get_depth_controllers"):
		return
	var controllers = item.get_depth_controllers()
	var item_l = item.get_layer()
	for dc in controllers:
		var idx = layers[item_l].find(dc)
		if idx != -1:
			layers[item_l].remove(idx)
			item.queue_free()


# Switch the active layer. All elements in old layer are inactive.
# All elements in new_layer are active.
func set_current_layer(new_layer: int):
	if new_layer == current_layer:
		return
	for item in layers[current_layer]:
		item.set_active(false)
	for item in layers[new_layer]:
		item.set_active(true)
	current_layer = new_layer
	emit_signal("layer_changed", new_layer)


func is_switch_valid(to: int):
	return to >= 0 and to < len(layers)


func _on_switch_layer_pressed(new_layer, node):
	if is_switch_valid(new_layer):
		node.set_layer(new_layer)
		set_current_layer(new_layer)


func _on_segment_changed(segment, state):
	if segment == null:
		return
	match state:
		SegmentState.ALIVE:
			add(segment.get_layer(), segment)
		SegmentState.DEAD:
			remove(segment)
			segment.queue_free()


func _on_layer_visibility_changed(layer, is_visible):
	var f = "start_peek" if is_visible else "end_peek"
	var arr := []
	if layer >= 0 and layer < len(layers):
		arr = layers[layer]
	for item in arr:
		item.call(f)


func _on_dc_tree_exited(layer, dc):
	var idx = layers[layer].find(dc)
	if idx == -1:
		return
	layers[layer].remove(idx)