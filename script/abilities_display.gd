#
# abilities_display.gd is a hotbar of sorts that displays the
# current state of the player's abilities.
#
# It is mostly used to show if abilities are ready, or how much longer
# is left on the cooldown before they can be used again.
#
extends Control

const FILL_SHADER = preload("res://shader/fill.tres")
const SAMPLE_IMAGE = preload("res://img/mini.png")
const ENABLED_MOD := Color(1.0, 1.0, 1.0, 1.0)
const DISABLED_MOD := Color(0.7, 0.7, 0.7, 0.7)

var ability_map := {}
var param_map := {}


func _ready() -> void:
	pass


func _reset() -> void:
	for child in $Box.get_children():
		$Box.remove_child(child)
		child.queue_free()
	
	ability_map.clear()
	param_map.clear()


func _on_abilities_ready(arr: Array) -> void:
	_reset()
	for ability in arr:
		_on_ability_added(ability)
	

func _on_ability_added(ability: Ability) -> void:
# create a portrait for the ability, and set it to the state of the ability
	var rect = TextureRect.new()
	if ability is Object and ability.has_method("get_texture"):
		rect.texture = ability.get_texture()
	else:
		rect.texture = SAMPLE_IMAGE
	rect.material = ShaderMaterial.new()
	rect.material.shader = FILL_SHADER
	rect.material.set_shader_param("fill_color", DISABLED_MOD)

	$Box.add_child(rect)
	ability_map[ability] = rect
	rect_min_size = $Box.rect_min_size
	_on_ability_is_ready_changed(ability, ability.is_ready)


func _on_ability_is_ready_changed(ability: Ability, is_ready: bool) -> void:
# grey out and partial the ability portrait if not ready, otherwise display in colour
	var next_mod = 0.0 if is_ready else 1.0
	if not param_map.has(ability):
		param_map[ability] = ShaderParam.new("proportion", "border_alpha", ability_map[ability].material)
	var start_value = param_map[ability].get_param()
	if start_value == null: return
	$Tween.stop(param_map[ability], "param")
	$Tween.interpolate_property(
		param_map[ability], "param", start_value, next_mod, 1.0, Tween.TRANS_SINE
	)
	$Tween.start()
	# If ability is ready, flash the ability red a few times
	if next_mod == 0:
		for _i in range(3):
			yield($Tween, "tween_completed")
			$Tween.interpolate_property(
				param_map[ability], "param2", 0.0, 1.0, 0.5, Tween.TRANS_SINE
			)
			$Tween.start()


func _on_ability_is_ready_changed_cd(ability, is_ready: bool, duration: float) -> void:
# grey out and partial fill ability if not ready
	var rect: TextureRect = ability_map[ability]
	if not param_map.has(ability):
		var material: ShaderMaterial = rect.material
		param_map[ability] = ShaderParam.new("proportion", "border_alpha", material)
	if not is_ready:
		param_map[ability].set_param2(0.0)
		$Tween.stop(param_map[ability], "param")
		$Tween.interpolate_property(param_map[ability], "param", 1.0, 0.0, duration)
		$Tween.start()
	else:
		$Tween.interpolate_property(
			param_map[ability], "param2", 0.0, 1.0, 1.0, Tween.TRANS_SINE
		)
		$Tween.start()


# To use me, get rid of Ability typehints and add to _ready()
func _test_on_ability_is_ready_changed():
	var dummy := []
	dummy.append(5)
	dummy.append(10)
	_on_abilities_ready(dummy)
	yield(get_tree().create_timer(5.0), "timeout")
	_on_ability_is_ready_changed(5, false)
	yield(get_tree().create_timer(5.0), "timeout")
	_on_ability_is_ready_changed(5, true)


# To use me, get rid of Ability typehints and add to _ready()
func _test_on_ability_is_ready_changed_cd():
	var dummy := [5, 10]
	_on_abilities_ready(dummy)
	yield(get_tree().create_timer(2.5), "timeout")
	_on_ability_is_ready_changed_cd(5, false, 10.0)
	_on_ability_is_ready_changed_cd(10, false, 20)


# ShaderParam stores some parameters for a shader, and allows them
# to be set through code. The point of this class is that doing it
# this way allows for interpolation of shader paramters with a Tween
# node.
class ShaderParam:
	var name: String
	var name2: String
	var material: ShaderMaterial
	var param setget set_param, get_param
	var param2 setget set_param2, get_param2

	func _init(param_name: String, param_name2: String, mat: ShaderMaterial) -> void:
		name = param_name
		name2 = param_name2
		material = mat

	func set_param(value) -> void:
		material.set_shader_param(name, value)

	func get_param():
		return material.get_shader_param(name)
	
	func set_param2(value) -> void:
		material.set_shader_param(name2, value)
	
	func get_param2():
		return material.get_shader_param(name2)
