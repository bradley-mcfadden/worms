#
# noise_manager.gd
# Noise manager will determine if a noise is close enough to a listener 
# for the listener to be cared, and if so it delivers the noise through
# the listener's on_noise_heard(Vector2) method. 
#
extends Node

# Nodes that should be notified when a noise happens
onready var listeners := []


func _on_noise_produced(position: Vector2, radius: int) -> void:
# Handles connect nodes' noises, then notifies listeners when
# they should have heard a noise.
# Listeners must have a hear_radius: int
#                   and on_noise_heard: Vector2
	for listener in listeners:
		var hear_radius: int = listener.hear_radius
		if (position - listener.global_position).length() - radius < hear_radius:
			listener.on_noise_heard(position)
