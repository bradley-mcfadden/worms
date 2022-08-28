extends Ability

var is_ready = true

export(int) var factor = 2


func invoke():
	parent.max_speed *= 2
	parent.acceleration *= 2
	is_ready = false
	$Duration.start()
	emit_signal("is_ready_changed_cd", self, is_ready, $Cooldown.wait_time + $Duration.wait_time)


func _on_Duration_timeout():
	parent.max_speed /= 2
	parent.acceleration /= 2
	$Cooldown.start()


func _on_Cooldown_timeout():
	is_ready = true
	emit_signal("is_ready_changed", self, is_ready)
