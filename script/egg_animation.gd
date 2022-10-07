#
# egg_animation
# Simple script to player the egg appearing animation and notify
# the tree when it's finished.#
#
extends Node2D


# Emitted when egg animation is finished playing.
signal animation_finished


func _ready() -> void:
	$AnimationPlayer.play("fade_in")


func _on_animation_finished(_anim_name: String) -> void:
	emit_signal("animation_finished")