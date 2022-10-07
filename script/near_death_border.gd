# 
# near_death_border.gd
# Script to manage the visibility of a flashing border indicating the
# player is near death.
#

extends TextureRect


func _on_health_state_changed(is_low: bool) -> void:
	visible = is_low
