#
# breakable_wall2.gd
# An obstacle that can be consecutively damaged or dashed through.
# Once its health hits 0, it can be passed through.
#

extends StaticBody2D


export (Array, Texture) var crack_textures = [
	load("res://img/textures/cracks1.png"),
	load("res://img/textures/cracks2.png"),
	load("res://img/textures/cracks3.png")
]
export (int) var start_health := 4
export (int) var layer := 1
export (float) var peek_alpha := 1.0

var health := start_health
onready var shape: SS2D_Shape_Open = $SS2D_Shape_Open


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()


func reset() -> void:
	health = start_health
	visible = true
	$CollisionPolygon2D.disabled = false
	$DepthController.reset()
	set_crack_texture(crack_textures[0])


func take_damage(how_much: int, _from: Node) -> void:
	var new_health: int = int(clamp(health - how_much, 0, start_health))
	if new_health <= 0:
		play_death_effects()
		$CollisionPolygon2D.disabled = true
	else:
		play_hit_effects()
		if new_health <= start_health * 0.66:
			set_crack_texture(crack_textures[1])
		elif new_health <= start_health * 0.33:
			set_crack_texture(crack_textures[2])
	health = new_health


func play_hit_effects() -> void:
	$Hit.play()
	$Tween.interpolate_property(self, "modulate", null, Color.black, 0.1)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property(self, "modulate", null, Color.white, 0.1)
	$Tween.start()


func play_death_effects() -> void:
	$Tween.stop(self)
	$Tween.interpolate_property(self, "modulate", null, Color.transparent, 0.1)
	$Tween.start()


func on_slammed() -> void:
	call_deferred("take_damage", health, null)


func set_crack_texture(texture: Texture) -> void:
	material.set_shader_param("mix_over", texture)
	shape.shape_material._edge_meta_materials[0].edge_material.material = material


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
