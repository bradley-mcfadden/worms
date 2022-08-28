# DepthController is meant to be managed by DepthManager
# It allows for automatically hiding a Node2D when it moves to an inactive
# layer. For nodes with collision, it also will disable it when the layer is
# inactive.
extends Node

signal hide
signal show

const COLLISION_OFFSET := 2

export(int) var depth_layer = 0

var start_mask
var start_layer
var parent: Node2D
var active


func _ready():
	parent = get_parent()

	if parent.has_method("set_collision_mask"):
		start_layer = parent.get_collision_layer()
		start_mask = parent.get_collision_mask()

		# var cl = start_layer + (COLLISION_OFFSET * depth_layer)
		# var cm = start_mask + (COLLISION_OFFSET * depth_layer)
		# print("Start layer ", start_layer, " ", (COLLISION_OFFSET * depth_layer))
		# print("Depth layer ", depth_layer)
		
		set_layer(parent.layer)


# Set whether this object is active. An active object is visible and collides,
# inactive objects are not visible and do not collide.
func set_active(is_active: bool):
	if is_active:
		emit_signal("show")
	else:
		emit_signal("hide")
	active = is_active


func start_peek():
	if parent.has_method("peek_start"):
		parent.peek_start()


func end_peek():
	if parent.has_method("peek_end"):
		parent.peek_end()


func get_layer() -> int:
	return depth_layer


# Change the controlled object's depth layer.
func set_layer(layer: int):
	# print("Call set layer on ", self, " with layer ", layer)
	if active == null:
		active = depth_layer == layer
	depth_layer = layer

	if parent.has_method("set_collision_mask"):
		set_collision_layer(start_layer << (2 * depth_layer))
		set_collision_mask(start_mask << (2 * depth_layer))

	parent.layer = layer


# Set the collision mask to the given layer. Does not allow for multiple masks
# to be set.
func set_collision_mask(layer: int):
	parent.set_collision_mask(layer)
	# print("new cm ", layer)


# Set the collision layer to the given layer. Does not allow for multiple layers
# to be set.
func set_collision_layer(layer: int):
	parent.set_collision_layer(layer)
	# print("new cl ", layer)


# Reset parent's collision layer and mask to match its initial depth value.
func reset():
	if parent.has_method("set_collision_mask"):
		set_collision_layer(start_layer)
		set_collision_mask(start_mask)

		depth_layer = start_layer


# Finds the base 2 log for a number.
func log2(val: int) -> int:
	var counter := 0
	var val2 = val
	while val2 > 1:
		val2 >>= 1
		counter += 1
	return counter
