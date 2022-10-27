# depth_manager.gd
# DepthManager allows for grouping nodes into layers.
# One layer at a time is considered active, and the others inactive.
# This should work with DepthController to make shapes that would normally
# collide slide past each other and make invisible all but the current layer.
extends Node

# Emitted when the active layer is changed
signal layer_changed(to) # int
# Emitted when the physical count of the number of layers changes.
signal number_of_layers_changed(to) # int
# Emitted when a layer has started/stopped being peeked
signal layer_peeked(visible) # bool

enum SegmentState { ALIVE, DEAD }

var layers := []
onready var current_layer := 0


func _ready() -> void:
	layers.append([])
	emit_signal("layer_changed", current_layer)


func add_items(items: Array) -> void:
#
# add_items
# Adds a group of items with DepthControllers to the manager.
# items - Nodes with depth controllers to add.
# 
	# print("Add group of items ", items)
	for item in items:
		if item.has_method("get_layer"):
			add(item.get_layer(), item)


func add(layer: int, item: Node) -> void:
# add
# Add a node to the specified layer.
# layer - Depth layer to add the item to. Created if it doesn't exist.
# item - Node to add to the manager. Should not be null.
#
	if not item.has_method("get_depth_controllers"):
		return
	# print("Add ", item, " to layer ", layer)
	var prev_len: int = len(layers)
	while len(layers) <= layer:
		layers.append([])
	if prev_len != len(layers):
		emit_signal("number_of_layers_changed", len(layers))

	var controllers: Array = item.get_depth_controllers()
	for dc in controllers:
		layers[layer].append(dc)
		if not dc.is_connected("tree_exited", self, "_on_dc_tree_exited"):
			dc.connect("tree_exited", self, "_on_dc_tree_exited", [layer, dc])
		dc.set_layer(layer)
		dc.set_active(layer == current_layer, current_layer)
		
	#print("add ", layer, " ", item, " ", len(controllers))


func switch(to: int, item: Node) -> void:
#
# switch
# Switch the position of item to the layer `to`.
# Cause item to become active or inactive depending on whether the new layer is
# active.
# to - Layer to switch item to. Should already exist as a layer.
# item - Node to move from its current layer to `to`
#
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
		dc.set_active(to == current_layer, current_layer)


func switch_if_safe(to: int, item: Node) -> bool:
# 
# switch_if_safe
# Switch `item` to depth layer `to`, but check that the layer
# exists beforehand. Return if the layer exists.
# to - Depth layer to move `item` to.
# item - Node to move to the new layer.
# return - True if layer `to` exists, false otherwise.
#
	if is_switch_valid(to):
		switch(to, item)
		return true
	return false


func remove(item: Node) -> void:
#
# remove
# Complete remove `item` from the depth_manager
# item - Non-null item to remove. The item with not be restored to being visible or colliding.
#
	if not item.has_method("get_depth_controllers"):
		return
	var controllers = item.get_depth_controllers()
	var item_l = item.get_layer()
	for dc in controllers:
		var idx = layers[item_l].find(dc)
		if idx != -1:
			layers[item_l].remove(idx)


func set_current_layer(new_layer: int) -> void:
#
# set_current_layer
# Switch the active layer. All elements in old layer are inactive.
# All elements in new_layer are active.
# new_layer - Depth layer that shall become the new active layer.
#
	emit_signal("layer_changed", new_layer)
	if new_layer == current_layer:
		return
	for item in layers[current_layer]:
		# print(item.get_parent())
		item.set_active(false, current_layer)
	for item in layers[new_layer]:
		item.set_active(true, current_layer)
	current_layer = new_layer


func is_switch_valid(to: int) -> bool:
#
# is_switch_valid
# Check that layer `to` exists in the current array of layers.
# to - Layer to check if exists.
# return - True if the layer exists, false otherwise.
#
	return to >= 0 and to < len(layers)


func _on_switch_layer_pressed(new_layer: int, node: Node) -> void:
	if is_switch_valid(new_layer):
		node.set_layer(new_layer)
		set_current_layer(new_layer)


func _on_segment_changed(segment: Node, state: Object) -> void:
	if segment == null:
		return
	match state:
		SegmentState.ALIVE:
			add(segment.get_layer(), segment)
		SegmentState.DEAD:
			remove(segment)


func _on_layer_visibility_changed(layer: int, is_visible: bool) -> void:
	# print("_on_layer_visbility_changed", layer, "", is_visible)
	var f = "start_peek" if is_visible else "end_peek"
	var g = "end_peek" if is_visible else "start_peek"
	var arr := []
	if layer >= 0 and layer < len(layers):
		arr = layers[layer]
		emit_signal("layer_peeked", is_visible)
		for item in arr:
			item.call(f, layer)
		for item in layers[current_layer]:
			item.call(g, layer)


func _on_dc_tree_exited(layer: int, dc: Node) -> void:
	var idx = layers[layer].find(dc)
	if idx == -1:
		return
	layers[layer].remove(idx)
