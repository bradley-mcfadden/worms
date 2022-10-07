# bullet.gd
# Attaches to the bullet scene, and provides the travel code for the bullet
# as well as handles collisions.

extends Area2D

# Emitted when the bullet should be cleaned up
signal bullet_destroyed(bullet) # Bullet

# Color of player blood
export(Color) var player_color := Color(0.17, 0.15, 0.19, 1.0)
# Color of enemy blood
export(Color) var enemy_color := Color(0.28, 0.03, 0.03, 1.0)

var shot_by: Node = null
var velocity: Vector2 = Vector2.ZERO
var damage := 0
var lifetime := 10.0
var layer := 0


func setup(
	shot_by: Node, velocity: Vector2, damage: int, 
	lifetime: float, cmask: int, layer: int
) -> void:
#
# setup initializes the bullet with variables it needs to keep track of.
# shot_by - Which game entity shot the bullet?
# velocity - Direction and speed of bullet
# damage - Amount of damage an enemy should take when struck.
# lifetime - Amount of time the bullet should fly for.
# cmask - Collision mask of the bullet, which layers does it check for collisions?
# clayer - Collision layer, which collision layers is it in?
#
	self.shot_by = shot_by
	self.velocity = velocity
	self.damage = damage
	self.lifetime = lifetime
	self.collision_mask = cmask
	self.layer = layer


func get_layer() -> int:
	return $DepthController.get_layer()


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func _ready() -> void:
	$Timer.wait_time = lifetime
	$Timer.start()


func _physics_process(delta: float) -> void:
	position += velocity * delta
	look_at(position + velocity)


func _on_Bullet_body_entered(body: PhysicsBody2D) -> void:
	if body.has_method("take_damage") and body != shot_by:
		body.take_damage(damage, shot_by)
		$Timer.stop()
		$AttackHit.emitting = true
		velocity = Vector2.ZERO
		$Timer.wait_time = $AttackHit.lifetime
		$Timer.start()
		$AttackHit.color = player_color if body is KinematicBody2D else enemy_color
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		$Sprite.visible = false
		$BulletTrail.visible = false


func _on_Timer_timeout() -> void:
	destroy()
	# pass


func destroy() -> void:
	emit_signal("bullet_destroyed", self)
	queue_free()
