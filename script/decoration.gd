#
# decoration.gd
#
# Attach this to a node that belongs to a layer, has no collision, and
# should be hidden when the layer is changed.
#
# The node should have a child called DepthController with depth_controller.gd

extends Node

export var layer := 0


func _ready() -> void:
	set_layer(layer)


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_layer() -> int:
	return $DepthController.get_layer()


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func _on_hide(_new_layer: int) -> void:
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.1)
	$Tween.start()


func _on_show(_new_layer: int) -> void:
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.1)
	$Tween.start()
