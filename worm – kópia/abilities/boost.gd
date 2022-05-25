extends Ability

var is_ready = true

export (int) var factor = 2

func invoke():
	if is_ready:
		parent.max_speed *= 2
		parent.acc *= 2
		is_ready = false
		$Duration.start()


func _on_Duration_timeout():
	parent.max_speed /= 2
	parent.acc /= 2
	$Cooldown.start()


func _on_Cooldown_timeout():
	is_ready = true
