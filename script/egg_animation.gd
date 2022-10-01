extends Node2D


signal animation_finished


func _ready():
	$AnimationPlayer.play("fade_in")


func _on_animation_finished(_anim_name:String):
	emit_signal("animation_finished")