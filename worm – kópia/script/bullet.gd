extends Area2D

var shot_by = null
var velocity = Vector2.ZERO
var damage = 0
var lifetime = 10


func setup(shot_by, velocity, damage, lifetime, cmask):
	self.shot_by = shot_by
	self.velocity = velocity
	self.damage = damage
	self.lifetime = lifetime
	self.collision_mask = cmask


func _ready():
	look_at(velocity)
	$Timer.wait_time = lifetime
	$Timer.start()


func _physics_process(delta):
	position += velocity * delta


func _on_Bullet_body_entered(body):
	if body.has_method("take_damage") and body != shot_by:
		body.take_damage(damage, shot_by)
		$Timer.stop()
		queue_free()


func _on_Timer_timeout():
	queue_free()
