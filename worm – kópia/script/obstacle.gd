tool
extends Node2D

export var layer := 0
export (Texture) var texture = null
export (PoolVector2Array) var uvs = PoolVector2Array()

var colors = PoolColorArray()

func _process(_delta):
	update()


func _draw():
	draw_polygon($StaticBody2D/CollisionPolygon2D.polygon, colors, uvs, texture)


func get_layer() -> int:
	return layer


func get_depth_controllers() -> Array:
	return [$DepthController, ]
