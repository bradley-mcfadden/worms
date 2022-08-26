extends Control

const RATE_OF_CHANGE := 0.2


func _ready():
	#_test_change_depth()
	pass


func set_maximum_depth(to: int):
	$VSlider.max_value = to
	$VSlider.tick_count = to


func change_depth(to: int):
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


func _on_DepthManager_layer_changed(to: int):
	change_depth(to)


func _on_DepthManager_number_of_layers_changed(to: int):
	set_maximum_depth(to)


func _test_change_depth():
	set_maximum_depth(10)
	change_depth(4)
