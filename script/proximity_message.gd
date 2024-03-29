# 
# proximity_message.gd
#
# Functions as a pressure pad that causes a message to appear when the player'head moves through it.

extends Area2D


class_name ProximityMessage, "res://icons/proximity_message.svg"


export (Color) var invisible_mod := Color(1.0, 1.0, 1.0, 0.0)
export (Color) var visible_mod := Color(1.0, 1.0, 1.0, 1.0)
export (String, MULTILINE) var text := "sample text"

export (int) var layer := 0
export (float) var radius := 200.0
export (int) var min_width := 800


func _ready() -> void:
	modulate = invisible_mod
	set_layer(layer)
	$Label.text = text
	modulate = invisible_mod
	$CollisionShape2D.shape.radius = radius
	$Label.rect_min_size.x = min_width


func _is_player_head(body: PhysicsBody2D) -> bool:
	var par: Node = body.get_parent()
	return par != null and par.has_method("add_segment") and par.head == body


func _on_ProximityMessage_body_entered(body: PhysicsBody2D) -> void:
	if _is_player_head(body):
		$Tween.stop(self)
		$Tween.interpolate_property(self, "modulate", invisible_mod, visible_mod, 2.0)
		if $Tween.is_inside_tree():
			$Tween.start()


func _on_ProximityMessage_body_exited(body: PhysicsBody2D) -> void:
	if _is_player_head(body):
		$Tween.stop(self)
		$Tween.interpolate_property(self, "modulate", visible_mod, invisible_mod, 2.0)
		if $Tween.is_inside_tree():
			$Tween.start()


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
