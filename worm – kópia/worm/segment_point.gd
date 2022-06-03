extends KinematicBody2D


onready var j1 := $Joint1
onready var j2 := $Joint2
onready var base: float = j1.position.distance_to(j2.position)
onready var theta := 0.0

var jj1 = Vector2.ZERO
var jj2 = Vector2.ZERO

func _ready():
	pass


func add_camera(cam):
	add_child(cam)


func _process(_delta):
	update()


func _draw():
	draw_line(j1.position, j2.position, Color.red, 5.0)


func move(vel, oscvel):
	# var hit := test_move(transform, vel, true)
	# var lv := move_and_slide(vel, Vector2.ZERO, false, 4, PI * 0.25, true)

	# look_at(lv + position)
	# self.position += vel
	# look_at(vel + self.position)
	###
	
	position = j1.position + (j2.position - j1.position) / 2

	
	var osc_offset = oscvel * int(sin(theta) * vel.length())
	# j1.position += vel.rotated(rot)
	# j2.position += Vector2(vel.x + base - sqrt(base * base - vel.y * vel.y), 0).rotated(rot)
	
	$Collision.position = osc_offset#.rotated(rot)
	$Image.position = osc_offset
	
	position += vel# .rotated(rot)
	rotation = vel.angle()
