tool

extends StaticBody2D


export (Texture) var fill_texture = load("res://img/textures/blue_ice.png")
export (Texture) var crack_texture = load("res://img/textures/cracks1.png")
export (float) var width = 40.0
export (float) var height = 40.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#update()
	pass


func _draw() -> void:
	#var shape: Vector2 = $CollisionShape2D.shape.extents
	# draw_polygon(
	# 	PoolVector2Array([-shape, -shape + 2.0 * shape.x * Vector2.RIGHT, shape, -shape + 2.0 * shape.y * Vector2.DOWN]),
	# 	PoolColorArray([Color.white, Color.white, Color.white, Color.white]), PoolVector2Array([Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)]),
	# 	fill_texture
	# )
	# draw_polygon(
	# 	PoolVector2Array([-shape, -shape + 2.0 * shape.x * Vector2.RIGHT, shape, -shape + 2.0 * shape.y * Vector2.DOWN]),
	# 	PoolColorArray([Color.white, Color.white, Color.white, Color.white]), PoolVector2Array([Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)]),
	# 	crack_texture
	# )
	pass


func _process(_delta: float) -> void:
	pass
	#update()
