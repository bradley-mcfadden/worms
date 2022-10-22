# 
# cursor.gd is a class that creates a cursor that
# by default follows the mouse.
#

extends Node


# Speed at which the cursor rotates.
export (float) var rotate_factor := 3.0
# Stores world position of cursor.
onready var cursor_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _physics_process(delta: float) -> void:
	$Sprite.rotation += delta * rotate_factor
	
	var viewport: Viewport = get_viewport()
	var mouse_pos_rel_view: Vector2 = viewport.get_mouse_position()
	var mouse_pos_global: Vector2 = viewport.canvas_transform.affine_inverse().xform(mouse_pos_rel_view)
	$Sprite.global_position = Vector2(mouse_pos_global.x, mouse_pos_global.y)
	cursor_position = mouse_pos_global
