#
# black_bars.gd
# Methods to interpolate the modulatae of some black bars.
#


extends Control

export (float) var fade_duration := 0.5

const TRANSPARENT := Color(0.0, 0.0, 0.0, 0.0)

onready var tween := $Tween


func fade_in() -> void:
	for node in [$Left, $Right]:
		tween.stop(node)
		tween.interpolate_property(node, "modulate", TRANSPARENT, Color.black, fade_duration)
		tween.start()


func fade_out() -> void:
	for node in [$Left, $Right]:
		tween.stop(node)
		tween.interpolate_property(node, "modulate", Color.black, TRANSPARENT, fade_duration)
		tween.start()


func _on_layer_peeked(visible: bool) -> void:
	if visible:
		fade_in()
	else:
		fade_out()
