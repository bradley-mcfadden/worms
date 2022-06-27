tool
extends KinematicBody2D

signal died(node, killer, overkill)
signal switch_layer_pressed(new_layer, node)

enum State {PLAYER_ALIVE=20, PLAYER_DEAD=40}

export (int) var start_health = 100
export (int) var layer = 0

var vel := Vector2.ZERO
var health = start_health
var current_state = State.PLAYER_ALIVE
var start_transform 


func _ready():
	set_layer(layer)
	print("Player", collision_layer, " ", collision_mask)
	start_transform = get_transform()
	$DepthController.set_layer(layer)
	randomize()


func _process(_delta):
	update()


func _draw():
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
	draw_arc(Vector2.ZERO, 21, 0, 2*PI, 20, Color.black)


func _physics_process(delta):
	if Engine.editor_hint: return
	match current_state:
		State.PLAYER_ALIVE: 
			move_and_collide(vel)
			look_at(position+vel)
		State.PLAYER_DEAD: pass


func _input(event):
	if Input.is_action_just_pressed("layer_up"):
		emit_signal("switch_layer_pressed", get_layer()+1, self)
	elif Input.is_action_just_pressed("layer_down"):
		emit_signal("switch_layer_pressed", get_layer()-1, self)


func _on_Timer_timeout():
	var angle := rand_range(0, 2 * PI)
	vel = Vector2(cos(angle), sin(angle))


func reset():
	current_state = State.PLAYER_ALIVE
	health = start_health
	vel = Vector2.ZERO
	transform = start_transform
	$Timer.start()


func get_entity_positions() -> Array:
	return [global_position]


func get_state():
	return State.PLAYER_ALIVE


func take_damage(how_much, from):
	print("Player is taking " + str(how_much) + " damage")
	if health > 0: health -= how_much
	if health < start_health * -0.25:
		emit_signal("died", self, from, true)
		current_state = State.PLAYER_DEAD
		$Timer.stop()
	elif health <= 0:
		emit_signal("died", self, from, false)
		current_state = State.PLAYER_DEAD
		$Timer.stop()


func is_alive() -> bool:
	return health > 0


func get_layer() -> int:
	return $DepthController.get_layer()


func set_layer(new_layer:int):
	$DepthController.set_layer(new_layer)


func get_depth_controllers() -> Array:
	return [$DepthController,]
