extends Control

const FILL_SHADER = preload("res://scene/fill.tres") 
const SAMPLE_IMAGE = preload("res://img/mini.png")
const ENABLED_MOD := Color(1.0, 1.0, 1.0, 1.0)
const DISABLED_MOD := Color(0.5, 0.5, 0.5, 0.5)

var ability_map := {}
var param_map := {}


func _ready():
	pass


func _on_abilities_ready(arr: Array):
	var rect: TextureRect
	for ability in arr:
		rect = TextureRect.new()
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


func _on_ability_is_ready_changed(ability, is_ready: bool):
	print("is_ready_changed ", is_ready)
	var next_mod = 0.0 if is_ready else 1.0
	if not param_map.has(ability):
		param_map[ability] = ShaderParam.new("proportion", ability_map[ability].material)
	var start_value = param_map[ability].get_param()
	$Tween.stop(param_map[ability], "param")
	$Tween.interpolate_property(param_map[ability], "param", start_value, next_mod, 1.0, Tween.TRANS_SINE)
	$Tween.start()


# TODO: test me
func _on_ability_is_ready_changed_cd(ability, is_ready: bool, duration: float):
	var rect: TextureRect = ability_map[ability]
	if not is_ready:
		var material: ShaderMaterial = rect.material
		if not param_map.has(ability):
			param_map[ability] = ShaderParam.new("proportion", material)
		$Tween.stop(param_map[ability], "param")
		$Tween.interpolate_property(param_map[ability], "param", 1.0, 0.0, duration)
		$Tween.start()


func _test_on_ability_is_ready_changed():
	var dummy := []
	dummy.append(5)
	dummy.append(10)
	_on_abilities_ready(dummy)
	yield(get_tree().create_timer(5.0), "timeout")
	_on_ability_is_ready_changed(5, false)
	yield(get_tree().create_timer(5.0), "timeout")
	_on_ability_is_ready_changed(5, true)


func _test_on_ability_is_ready_changed_cd():
	var dummy := [5, 10]
	_on_abilities_ready(dummy)
	yield(get_tree().create_timer(2.5), "timeout")
	_on_ability_is_ready_changed_cd(5, false, 10.0)
	_on_ability_is_ready_changed_cd(10, false, 20)


class ShaderParam:
	var name: String 
	var material: ShaderMaterial
	var param setget set_param, get_param

	func _init(param_name: String, mat: ShaderMaterial):
		name = param_name
		material = mat

	func set_param(value):
		material.set_shader_param(name, value)
	

	func get_param():
		return material.get_shader_param(name)

