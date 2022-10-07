#
# depth_meter.gd
# Small GUI element that displays the current depth layer to the player,
# as well as their place within the total height of the map.

extends Control

const RATE_OF_CHANGE := 0.2


func _ready() -> void:
	#_test_change_depth()
	pass


func set_maximum_depth(to: int) -> void:
#
# set_maximum_depth
# Used to inform the slider of how many layers there are.
# to - Number of depth layers
#
	$VSlider.max_value = to
	$VSlider.tick_count = to


func change_depth(to: int) -> void:
#
# change_depth
# Adjust this widget to display specified depth.
# to - Depth layer to display.
#
	var slider: VSlider = $VSlider
	$Tween.interpolate_property(
		slider,
		"value",
		slider.value,
		to,
		abs(slider.value - to) * RATE_OF_CHANGE,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)
	$Tween.start()
	$DepthValue.text = str(to)


func _on_DepthManager_layer_changed(to: int) -> void:
	change_depth(to)


func _on_DepthManager_number_of_layers_changed(to: int) -> void:
	set_maximum_depth(to)


func _test_change_depth() -> void:
	set_maximum_depth(10)
	change_depth(4)
