#
# laser_node.gd
# Contains code for the nodes of the laser wire.
#
extends Sprite


class_name LaserNode, "res://icons/laser_node.svg"


func fire() -> void:
#
# fire
# Fire this node, calling any animations or effects that it should use.
#
	$MuzzleFlash.emitting = true
	$AnimationPlayer.play("fire")


func cooldown() -> void:
#
# cooldown
# Cooldown callback for the node.
#
	$AnimationPlayer.play("cooldown")
