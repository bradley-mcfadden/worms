extends Node

class_name Ability

signal is_ready_changed(ability, is_ready)
signal is_ready_changed_cd(ability, is_ready, duration)

export(Texture) var texture
var parent
var is_ready := false


func invoke():
	pass


func get_texture() -> Texture:
	return texture
