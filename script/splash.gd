#
# splash.gd 
# Script for showing a splash screen before the title screen.
#

extends Control


onready var tween: Tween = $Tween


func _ready() -> void:
	var _res = tween.interpolate_property(self, "modulate", null, Color.white, 1.0)
	_res = tween.start()
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(3.0), "timeout")
	_res = tween.interpolate_property(self, "modulate", null, Color.black, 1.0)
	_res = tween.start()
	yield(tween, "tween_completed")
	_res = get_tree().change_scene("res://scene/TitleScreen.tscn")
