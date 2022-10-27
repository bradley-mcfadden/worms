#
# depth_controller.gd 
# Is meant to be managed by depth_manager.gd
# It allows for automatically hiding a Node2D when it moves to an inactive
# layer. For nodes with collision, it also will disable collision when the layer is
# inactive.
extends Node

# Emitted when the node is hidden
signal hide
# Emitted when the node is shown
signal show

const COLLISION_OFFSET := 2

export(int) var depth_layer := 0

# Starting collision mask
var start_mask: int
# Starting collision layer
var start_layer: int
var parent: Node2D
var active: bool = false


func _ready() -> void:
	parent = get_parent()

	if parent.has_method("set_collision_mask"):
		start_layer = parent.get_collision_layer()
		start_mask = parent.get_collision_mask()
		
		set_layer(parent.layer)


func set_active(is_active: bool):
#
# set_active
# Set whether this object is active. An active object is visible and collides,
# inactive objects are not visible and do not collide.
# set_active - Should the object be visible and collide?
#
	if is_active:
		emit_signal("show")
	else:
		emit_signal("hide")
	active = is_active


func start_peek() -> void:
#
# start_peek
# If the parent should be partially shown on the peek action,
# then show it.
#
	if parent.has_method("start_peek"):
		parent.start_peek()


func end_peek() -> void:
#
# end_peek
# return the parent back to being hidden when a peek ends.
#
	if parent.has_method("end_peek"):
		parent.end_peek()


func get_layer() -> int:
#
# get_layer 
# return - The depth layer of the parent.
#
	return depth_layer


func set_layer(layer: int) -> void:
#
# set_layer
# Change the controlled object's depth layer.
# layer - Layer to change to.
#
	if active == null:
		active = depth_layer == layer
	depth_layer = layer
	parent.layer = layer
	if parent.has_method("set_collision_mask"):
		set_collision_layer(start_layer << (2 * depth_layer))
		set_collision_mask(start_mask << (2 * depth_layer))


func set_collision_mask(layer: int) -> void:
	parent.set_collision_mask(layer)


func set_collision_layer(layer: int) -> void:
	parent.set_collision_layer(layer)


func reset() -> void:
#
# reset
# Reset parent's collision layer and mask to match its initial depth value.
#
	if parent.has_method("set_collision_mask"):
		set_collision_layer(start_layer)
		set_collision_mask(start_mask)

		depth_layer = parent.layer
		set_layer(depth_layer)


func log2(val: int) -> int:
#
# log2
# Finds the n such that 2^n < val < 2^(n+1).
# That is, return n such that 2^n is the highest power of 2
# less than val.
# val - Number to find n for.
# return - Positive integer in range [0, 63]  
#
	var counter := 0
	var val2 = val
	while val2 > 1:
		val2 >>= 1
		counter += 1
	return counter
