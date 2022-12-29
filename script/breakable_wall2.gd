#
# breakable_wall2.gd
# An obstacle that can be consecutively damaged or dashed through.
# Once its health hits 0, it can be passed through.
#

extends StaticBody2D


class_name BreakableWall, "res://icons/breakable_wall.svg"


signal broke(is_broken) # boolean


export (Array, Texture) var crack_textures = [
	load("res://img/textures/cracks1.png"),
	load("res://img/textures/cracks2.png"),
	load("res://img/textures/cracks3.png")
]
export (int) var start_health := 4
export (int) var layer := 1
export (float) var peek_alpha := 1.0
export (Resource) var shape_material

var health := start_health
onready var shape: SS2D_Shape_Open = $SS2D_Shape_Open


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shape.shape_material = shape_material.duplicate()
	shape.shape_material.render_offset = 0
	reset()


func reset() -> void:
#
# reset() puts the object back into its level start state.
#
	health = start_health
	visible = true
	$CollisionPolygon2D.disabled = false
	$DepthController.reset()
	set_crack_texture(crack_textures[0])
	modulate = Color.white
	emit_signal("broke", false)


func take_damage(how_much: int, _from: Node, armor: bool = true) -> void:
#
# take_damage
# Make the object take damage. Unless armor is false, the amount of damage is reduce to 1
# how_much - Amount of damage for wall to take, reduced to 1 if armor is true.
# _from - Unused.
# armor - If true, reduce how_much to 1. 
#
	if armor: how_much = 1
	var new_health: int = int(clamp(health - how_much, 0, start_health))
	if new_health <= 0:
		play_death_effects()
		emit_signal("broke", true)
		$CollisionPolygon2D.call_deferred("set_disabled", true)
	else:
		play_hit_effects()
		if new_health <= start_health * 0.66:
			set_crack_texture(crack_textures[1])
		elif new_health <= start_health * 0.33:
			set_crack_texture(crack_textures[2])
	health = new_health
	$CollisionPolygon2D.call_deferred("set_disabled", true)
	yield(get_tree().create_timer(0.2), "timeout")
	if is_alive():
		$CollisionPolygon2D.call_deferred("set_disabled", false)


func play_hit_effects() -> void:
	$Tween.interpolate_property(self, "modulate", null, Color.black, 0.5)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property(self, "modulate", null, Color.white, 0.5)
	$Tween.start()
	var idx := int(rand_range(1, 4))
	var node := "Hit%d" % idx
	get_node(node).play()


func play_death_effects() -> void:
	$Tween.stop(self)
	$Tween.interpolate_property(self, "modulate", null, Color.transparent, 1.0)
	$Tween.start()
	$Destroy.play()
	yield(get_tree().create_timer(1.0), "timeout")
	visible = false


func on_slammed() -> void:
	call_deferred("take_damage", health, null, false)


func set_crack_texture(texture: Texture) -> void:
	material.set_shader_param("mix_over", texture)
	shape.shape_material._edge_meta_materials[0].edge_material.material = material


func on_bitten(worm: Node, bite_damage: int, _bite_heal_factor: float) -> void:
#
# on_bitten - A callback for a event when this flesh ball is hit by bite.
# bite_damage - Amount of damage the flesh ball should take.
# bite_heal_factor - Unused
#	
	call_deferred("take_damage", bite_damage, worm)


func is_alive() -> bool:
#
# is_alive
# Return true if object can still be damaged.
#
	return health > 0

## Mostly boilerplate below this line
#
#

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
