#
# flesh_ball.gd
# Ball of meat that functions as a harmless snack / powerup type object.
#

extends Area2D


export(int) var start_health := 1
export(int) var layer := 0

onready var health := start_health


func reset() -> void:
#
# reset to initial state.
# 
	health = start_health
	visible = true
	monitorable = true
	monitoring = true


func take_damage(how_much: int, _from: Node) -> void:
#
# take_damage
# how_much: damage to take
# _from: unused
# return: Nothing
#
	var new_health: int = int(clamp(health - how_much, 0, start_health))
	if new_health <= 0:
		visible = false
		monitorable = false
		monitoring = false
		$Gib.play()
		$BloodExplode.emitting = true
	health = new_health


func is_alive() -> bool:
#
# is_alive
# Is this thing still usable?
#
	return health > 0


func on_bitten(worm: Node, bite_damage: int, bite_heal_factor: float) -> void:
#
# on_bitten - A callback for a event when this flesh ball is hit by bite.
# bite_damage - Amount of damage the flesh ball should take.
# bite_heal_factor - Fraction of total health the player should heal per segment
#	
	call_deferred("take_damage", bite_damage, worm)
	worm.head.increment_blood_level()
	# When biting an enemy, add a segment
	worm.call_deferred("add_segment")
	# ... and heal each segment
	for segment in worm.body:
		segment.take_damage(-start_health * bite_heal_factor, worm)
		yield(get_tree().create_timer(0.1), "timeout")


func get_layer() -> int:
	return $DepthController.get_layer()


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]
