# Boost is a simple ability that provides the player with a decaying speed
# boost for a short duration.
extends Ability

# Amount of speed that player's speed cap and acceleration is multiplied by
export(float) var factor := 2.0


func setup() -> void:
	is_ready = true


func invoke() -> void:
# Multiply player speed and acc, setup timer, change ready state
	parent.max_speed *= factor
	parent.acceleration *= factor
	is_ready = false
	$Duration.start()
	emit_signal("is_ready_changed_cd", self, is_ready, $Cooldown.wait_time + $Duration.wait_time)


func _on_Duration_timeout() -> void:
	parent.max_speed /= factor
	parent.acceleration /= factor
	$Cooldown.start()


func _on_Cooldown_timeout() -> void:
	is_ready = true
	emit_signal("is_ready_changed", self, is_ready)
