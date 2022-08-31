extends TextureRect


func _on_health_state_changed(is_low: bool):
	visible = is_low
