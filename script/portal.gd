#
# portal.gd
# Area that shows a colored border around where the user can ascend or descend.
# Green for descend, red for ascend.
# Later, this should also let the user peek when the player's head enters the area.
#

extends Area2D


export var layer := 0
export(float) var peek_alpha := 1.0
export(bool) var downward := true

const UPWARD_MODULATE = Color(1.0, 0.0, 0.0, 1.0)
const DOWNWARD_MODULATE = Color(0.0, 1.0, 0.0, 1.0)


var active: bool


func _ready() -> void:
	set_layer(layer)
	var _err := $DepthController.connect("show", self, "_on_show")
	_err = $DepthController.connect("hide", self, "_on_hide")


func get_collision_layer() -> int:
	return collision_layer


func set_collision_layer(new_layer: int) -> void:
	collision_layer = new_layer


func get_collision_mask() -> int:
	return collision_mask


func set_collision_mask(new_mask: int) -> void:
	collision_mask = new_mask


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_layer() -> int:
	return $DepthController.get_layer()


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func _on_hide(_new_layer: int) -> void:
	#end_peek_l(new_layer)
	pass


func _on_show(_new_layer: int) -> void:
	#start_peek_l(new_layer)
	pass


func _on_DepthManager_layer_changed(to: int) -> void:
	if to == layer and downward:
		$Tween.interpolate_property(
			self, "modulate", null, DOWNWARD_MODULATE, 0.1
		)
		$Tween.start()
	elif to == layer + 1 and downward:
		$Tween.interpolate_property(
			self, "modulate", null, UPWARD_MODULATE, 0.1
		)
		$Tween.start()
	else:
		$Tween.interpolate_property(
			self, "modulate", null, Color.transparent, 0.1
		)
		$Tween.start()
