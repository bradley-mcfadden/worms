#
# splash.gd 
# Script for showing a splash screen before the title screen.
#

extends Control


signal main_menu_loaded


onready var tween: Tween = $Tween
onready var can_cancel_splash := true
onready var main_menu_resource: Resource = preload("res://scene/ui/TitleScreen.tscn")


func _ready() -> void:
	var _res := 0
	if Configuration.sections.general.show_splash_startup:
		_res = tween.interpolate_property(self, "modulate", null, Color.white, 1.0)
		_res = tween.start()
		yield(tween, "tween_completed")
		$Timer.start()
		yield($Timer, "timeout")
	_res = tween.interpolate_property(self, "modulate", null, Color.black, 1.0)
	_res = tween.start()
	yield(tween, "tween_completed")
	AsyncLoader.change_scene_to(main_menu_resource)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if can_cancel_splash:
			$Timer.stop()
			can_cancel_splash = false
			AsyncLoader.change_scene_to(main_menu_resource)
