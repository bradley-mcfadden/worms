# Ability is an interface for creating "abilities"
# tracked by the display.
# Each ability does something when "invoked", and should have
# some texture.
extends Node

class_name Ability

# Emitted when the state of the ability changes
#warning-ignore:unused-signal
signal is_ready_changed(ability, is_ready) # Ability, bool
# Emitted when the satte of the ability changes, and duration is a cooldown
#warning-ignore:unused-signal
signal is_ready_changed_cd(ability, is_ready, duration) # Ability, bool, float

export(Texture) var texture
var parent
var is_ready := false


func setup() -> void:
# Setup that should be called "onready"
	pass


func invoke() -> void:
# Called when player uses the ability
	pass


func get_texture() -> Texture:
# get_texture associated with ability
	return texture
