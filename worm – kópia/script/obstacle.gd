tool
extends Node2D

export var layer := 0
export(Texture) var texture = null
export(PoolVector2Array) var uvs := PoolVector2Array()
export(PoolVector2Array) var points := PoolVector2Array()
export(float) var peek_alpha = 0.3

var colors = PoolColorArray()
var active


func _ready():
	set_layer(layer)
	$StaticBody2D/CollisionPolygon2D.polygon = points


func _process(_delta):
	update()


func _draw():
	draw_polygon(points, colors, uvs, texture)
	# if Engine.editor_hint:
	var array = copy(points)
	array.append(points[0])
	draw_polyline(array, Color.black)


func get_collision_layer() -> int:
	return $StaticBody2D.get_collision_layer()


func set_collision_layer(new_layer: int):
	print("obstacle ", $StaticBody2D.collision_layer, " to ", new_layer)
	$StaticBody2D.set_collision_layer(new_layer)


func get_collision_mask() -> int:
	return $StaticBody2D.get_collision_mask()


func set_collision_mask(new_mask: int):
	print("obstacle ", $StaticBody2D.collision_mask, " to ", new_mask)

	$StaticBody2D.set_collision_mask(new_mask)


func set_layer(new_layer: int):
	print("set_layer() to ", new_layer)
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


func _on_hide():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.0), 0.1)
	$Tween.start()


func _on_show():
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0.0), Color(1, 1, 1, 1), 0.1)
	$Tween.start()


func start_peek():
	$Tween.interpolate_property(
		self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, peek_alpha), 0.1
	)
	$Tween.start()


func end_peek():
	$Tween.interpolate_property(
		self, "modulate", Color(1, 1, 1, peek_alpha), Color(1, 1, 1, 0), 0.1
	)
	$Tween.start()
