#
# mock_player.gd
# Bare minimum player that moves randomly, can take damage, and can move layers.
# 
tool
extends KinematicBody2D

# Emitted when player dies
signal died(node, killer, overkill) # Node, Node, bool
# Emitted when the player want to switch to a new layer
signal switch_layer_pressed(new_layer, node) # int, Node

enum State { PLAYER_ALIVE = 20, PLAYER_DEAD = 40 }

export(int) var start_health := 100
export(int) var layer := 0

var vel := Vector2.ZERO
var health: int = start_health
var current_state = State.PLAYER_ALIVE
var start_transform: Transform2D


func _ready() -> void:
	set_layer(layer)
	print("Player", collision_layer, " ", collision_mask)
	start_transform = get_transform()
	$DepthController.set_layer(layer)
	randomize()


func _process(_delta: float) -> void:
	update()


func _draw() -> void:
	var color
	match current_state:
		State.PLAYER_ALIVE:
			color = Color.tomato
		State.PLAYER_DEAD:
			color = Color.blue
		_:
			color = Color.black
	draw_circle(Vector2.ZERO, 20, color)
	draw_line(Vector2.ZERO, Vector2.RIGHT * 21, Color.black)
	draw_arc(Vector2.ZERO, 21, 0, 2 * PI, 20, Color.black)


func _physics_process(_delta: float) -> void:
	if Engine.editor_hint:
		return
	match current_state:
		State.PLAYER_ALIVE:
			var _i = move_and_collide(vel)
			look_at(position + vel)
		State.PLAYER_DEAD:
			pass


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("layer_up"):
		emit_signal("switch_layer_pressed", get_layer() + 1, self)
	elif Input.is_action_just_pressed("layer_down"):
		emit_signal("switch_layer_pressed", get_layer() - 1, self)


func _on_Timer_timeout() -> void:
	var angle := rand_range(0, 2 * PI)
	vel = Vector2(cos(angle), sin(angle))


func reset() -> void:
# reset the player to their initial state.
	current_state = State.PLAYER_ALIVE
	health = start_health
	vel = Vector2.ZERO
	transform = start_transform
	$Timer.start()


func get_entity_positions() -> Array:
# get_entity_positions
# return - Position of player in an array.
	return [global_position]


func get_state() -> Object:
# get_state
# return - State of player. One of mock_player/State
	return State.PLAYER_ALIVE


func take_damage(how_much: int, from: Node) -> void:
#
# take_damage
# Cause the player to take damage from another node.
# how_much - Amount of damage this player should take.
# from - Entity that caused the damage.
#
	print("Player is taking " + str(how_much) + " damage")
	if health > 0:
		health -= how_much
	if health < start_health * -0.25:
		emit_signal("died", self, from, true)
		current_state = State.PLAYER_DEAD
		$Timer.stop()
	elif health <= 0:
		emit_signal("died", self, from, false)
		current_state = State.PLAYER_DEAD
		$Timer.stop()


func is_alive() -> bool:
#
# is_alive
# return - True if this player is still alive.
#
	return health > 0


func get_layer() -> int:
	return $DepthController.get_layer()


func set_layer(new_layer: int) -> void:
	$DepthController.set_layer(new_layer)


func get_depth_controllers() -> Array:
	return [
		$DepthController,
	]
