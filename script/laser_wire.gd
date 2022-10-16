# laser_wire.gd
# A multi-state wire that triggers a laser attack after a raycast collides
# with a body between the two nodes of the wire.

extends Node2D


enum DetectState { WAIT, PREFIRE, ANTICIPATE, FIRE, COOLDOWN }

export (Color) var invisible_mod := Color(1.0, 1.0, 1.0, 0.0)
export (Color) var visible_mod := Color(1.0, 1.0, 1.0, 1.0)
export (int) var layer := 0
export var state_properties := {
	DetectState.WAIT : {
		"width" : 1.0,
		"color" : Color(0.5, 0.0, 0.0, 0.5),
		"time" : 1.0
	},
	DetectState.PREFIRE : {
		"width" : 4.0,
		"color" : Color(0.8, 0.2, 0.0, 0.6),
		"time" : 1.0
	},
	DetectState.ANTICIPATE : {
		"width" : 16.0,
		"color" : Color(1.0, 0.0, 0.0, 0.0),
		"time" : 0.25
	},
	DetectState.FIRE : {
		"width" : 16.0,
		"color" : Color(1.0, 0.3, 0.3, 0.8),
		"time" : 0.25
	},
	DetectState.COOLDOWN : {
		"width" : 0.0,
		"color" : Color(1.0, 0.0, 0.0, 0.0),
		"time" : 2.0
	}
}

onready var ray: RayCast2D
onready var node1: LaserNode = $LaserNode
onready var node2: LaserNode = $LaserNode2
onready var state: int = DetectState.WAIT
onready var next_state: int = -1
onready var color: Color = state_properties[state]["color"]
onready var width: float = state_properties[state]["width"]
onready var damage: int = 100


func _ready() -> void:
	ray = $RayCast2D
	node1.look_at(node2.global_position)
	node2.look_at(node1.global_position)
	ray.global_position = node1.global_position
	ray.cast_to = node2.global_position - ray.global_position


func _draw() -> void:
	draw_line(node1.position, node2.position, color, width, true)


func _physics_process(_delta: float) -> void:
	if ray.is_colliding():
		if state == DetectState.WAIT and not $Tween.is_active():
			next_state = DetectState.PREFIRE 
			$Tween.interpolate_property(self, "width", null, state_properties[next_state]["width"], state_properties[state]["time"], Tween.TRANS_CUBIC)
			$Tween.interpolate_property(self, "color", null, state_properties[next_state]["color"], state_properties[state]["time"])
			$Tween.stop(self, "width")
			$Tween.stop(self, "color")
			$Tween.start()
		if state == DetectState.FIRE:
			# process the collider as a hit
			var collider: Object = ray.get_collider()
			if collider.has_method("take_damage") and collider.is_alive():
				collider.take_damage(damage, self)

func _process(_delta: float) -> void:
	update()


func _on_Tween_tween_completed(_obj: Object, _key: NodePath):
	state = next_state
	match state:
		DetectState.PREFIRE:
			next_state = DetectState.ANTICIPATE
		DetectState.ANTICIPATE:
			next_state = DetectState.FIRE
			node1.fire()
			node2.fire()
			$Laser.play()
		DetectState.FIRE:
			next_state = DetectState.COOLDOWN
			node1.cooldown()
			node2.cooldown()
		DetectState.COOLDOWN:
			next_state = DetectState.WAIT
		DetectState.WAIT:
			pass
	if next_state != state:
		$Tween.interpolate_property(self, "width", null, state_properties[next_state]["width"], state_properties[state]["time"], Tween.TRANS_CUBIC)
		$Tween.interpolate_property(self, "color", null, state_properties[next_state]["color"], state_properties[state]["time"])
		$Tween.stop(self, "width")
		$Tween.stop(self, "color")
		$Tween.start()


func get_collision_layer() -> int:
	return get_collision_mask()


func set_collision_layer(_new_layer: int) -> void:
	pass


func get_collision_mask() -> int:
	return $RayCast2D.collision_mask


func set_collision_mask(new_mask: int) -> void:
	$RayCast2D.collision_mask = new_mask


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_layer() -> int:
	return $DepthController.get_layer()


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]


func _on_hide() -> void:
	print("laser hide")
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0.0), 0.1)
	$Tween.start()


func _on_show() -> void:
	print("laser show")
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0.0), Color(1, 1, 1, 1), 0.1)
	$Tween.start()
	
