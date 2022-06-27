extends Area2D

signal bullet_destroyed(bullet)

var shot_by = null
var velocity = Vector2.ZERO
var damage = 0
var lifetime = 10
var layer := 0

func setup(shot_by, velocity, damage, lifetime, cmask, layer):
	self.shot_by = shot_by
	self.velocity = velocity
	self.damage = damage
	self.lifetime = lifetime
	self.collision_mask = cmask
	self.layer = layer


func get_layer() -> int:
	return $DepthController.get_layer()


func set_layer(new_layer:int):
	$DepthController.set_layer(new_layer)


func _ready():
	# look_at(velocity)
	$Timer.wait_time = lifetime
	$Timer.start()


func _physics_process(delta):
	position += velocity * delta


func _on_Bullet_body_entered(body):
	if body.has_method("take_damage") and body != shot_by:
		body.take_damage(damage, shot_by)
		$Timer.stop()
		destroy()


func _on_Timer_timeout():
	destroy()


func destroy():
	emit_signal("bullet_destroyed", self)
	queue_free()
