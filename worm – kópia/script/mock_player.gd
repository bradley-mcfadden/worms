extends KinematicBody2D

signal died(node, killer, overkill)

enum State {PLAYER_ALIVE=20, PLAYER_DEAD=40}

export (int) var start_health = 100

var vel := Vector2.ZERO
var health = start_health
var current_state = State.PLAYER_ALIVE


func _ready():
	randomize()
	current_state = State.PLAYER_ALIVE


func _process(_delta):
	update()


func _draw():
	var color
	match current_state:
		State.PLAYER_ALIVE:
			color = Color.tomato
		State.PLAYER_DEAD:
			color = Color.black
	draw_circle(Vector2.ZERO, 20, color)
	draw_arc(Vector2.ZERO, 21, 0, 2*PI, 20, Color.black)


func _physics_process(delta):
	match current_state:
		State.PLAYER_ALIVE: move_and_collide(vel)
		State.PLAYER_DEAD: pass


func _on_Timer_timeout():
	var angle := rand_range(0, 2 * PI)
	vel = Vector2(cos(angle), sin(angle))


func get_entity_positions() -> Array:
	return [global_position]


func get_state():
	return State.PLAYER_ALIVE


func take_damage(how_much, from):
	if health > 0: health -= how_much
	if health < start_health * -0.25:
		emit_signal("died", self, from, true)
		current_state = State.PLAYER_DEAD
	elif health < 0:
		emit_signal("died", self, from, false)
		current_state = State.PLAYER_DEAD


func is_alive() -> bool:
	return health > 0
