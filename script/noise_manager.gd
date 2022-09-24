extends Node

# Nodes that should be notified when a noise happens
onready var listeners := []

# Handles connect nodes' noises, then notifies listeners when
# they should have heard a noise.
# Listeners must have a hear_radius: int
#                   and on_noise_heard: Vector2
func _on_noise_produced(position: Vector2, radius: int):
	for listener in listeners:
		var hear_radius: int = listener.hear_radius
		if (position - listener.position).length() - radius - hear_radius:
			listener.on_noise_heard(position)
