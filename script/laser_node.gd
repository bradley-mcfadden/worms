#
# laser_node.gd
# Contains code for the nodes of the laser wire.
#
extends Sprite


class_name LaserNode


func fire() -> void:
#
# fire
# Fire this node, calling any animations or effects that it should use.
#
	$MuzzleFlash.emitting = true
