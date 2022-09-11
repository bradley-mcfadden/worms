extends Control

const FILL_SHADER = preload("res://shader/fill.tres")
const SAMPLE_IMAGE = preload("res://img/mini.png")
const ENABLED_MOD := Color(1.0, 1.0, 1.0, 1.0)
const DISABLED_MOD := Color(0.7, 0.7, 0.7, 0.7)

var ability_map := {}
var param_map := {}


func _ready():
	pass


func _reset():
	for child in $Box.get_children():
		$Box.remove_child(child)
		child.queue_free()
	
	ability_map.clear()
	param_map.clear()


func _on_abilities_ready(arr: Array):
	_reset()
	for ability in arr:
		_on_ability_added(ability)
	

func _on_ability_added(ability):
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


func _on_ability_is_ready_changed(ability, is_ready: bool):
	# print("is_ready_changed ", is_ready)
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
	if next_mod == 0:
		for _i in range(3):
			yield($Tween, "tween_completed")
			$Tween.interpolate_property(
				param_map[ability], "param2", 0.0, 1.0, 0.5, Tween.TRANS_SINE
			)
			$Tween.start()


func _on_ability_is_ready_changed_cd(ability, is_ready: bool, duration: float):
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
	var name2: String
	var material: ShaderMaterial
	var param setget set_param, get_param
	var param2 setget set_param2, get_param2

	func _init(param_name: String, param_name2: String, mat: ShaderMaterial):
		name = param_name
		name2 = param_name2
		material = mat

	func set_param(value):
		material.set_shader_param(name, value)

	func get_param():
		return material.get_shader_param(name)
	
	func set_param2(value):
		material.set_shader_param(name2, value)
	
	func get_param2():
		return material.get_shader_param(name2)
