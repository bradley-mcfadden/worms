tool
extends "res://addons/rmsmartshape/shapes/shape_open.gd"


export (Array, Texture) var crack_textures = [
	load("res://img/nothing.png"),
	load("res://img/textures/cracks1.png"),
	load("res://img/textures/cracks2.png"),
	load("res://img/textures/cracks3.png")
]
export (int) var start_health := 4
export (int) var layer := 1
export (float) var peek_alpha := 1.0

var health := start_health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_layer(layer)


func get_collision_layer() -> int:
	#return collision_layer
	return 0


func set_collision_layer(new_layer: int) -> void:
	#collision_layer = new_layer
	pass


func get_collision_mask() -> int:
	#return collision_mask
	return 2


func set_collision_mask(new_mask: int) -> void:
	#collision_mask = new_mask
	pass


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_layer() -> int:
	return $DepthController.get_layer()


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func _on_hide() -> void:
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.0), 0.1)
	$Tween.start()


func _on_show() -> void:
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