#
# obstacle.gd
# For managing obstacles that should not collide and not be active 
# when their layer is inactive. 
# Use for simple shapes, and obstacle_ssd.gd for more complex shapes.
#
tool
extends StaticBody2D

export var layer := 0
export(float) var peek_alpha := 1.0

var active: bool


func _ready() -> void:
	set_layer(layer)


func get_collision_layer() -> int:
	return collision_layer


func set_collision_layer(new_layer: int) -> void:
	collision_layer = new_layer


func get_collision_mask() -> int:
	return collision_mask


func set_collision_mask(new_mask: int) -> void:
	collision_mask = new_mask


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_layer() -> int:
	return $DepthController.get_layer()


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func copy(pool: PoolVector2Array) -> PoolVector2Array:
	var new_pool := PoolVector2Array()
	for vec in pool:
		new_pool.append(vec)
	return new_pool


func _on_hide(_new_layer: int) -> void:
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.0), 0.1)
	$Tween.start()


func _on_show(_new_layer: int) -> void:
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0.0), Color(1, 1, 1, 1), 0.1)
	$Tween.start()


func start_peek() -> void:
	$Tween.interpolate_property(
		self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, peek_alpha), 0.1
	)
	$Tween.start()


func end_peek() -> void:
	$Tween.interpolate_property(
		self, "modulate", Color(1, 1, 1, peek_alpha), Color(1, 1, 1, 0), 0.1
	)
	$Tween.start()
