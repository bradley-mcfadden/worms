extends Node2D

export var layer := 0


func _ready():
	set_layer(layer)


func set_layer(new_layer: int):
	$DepthController.set_layer(new_layer)


func get_layer() -> int:
	return $DepthController.get_layer()


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func _on_hide():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.1)
	$Tween.start()


func _on_show():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.1)
	$Tween.start()
