extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SPEED := 400

var head

onready var j1 := $Joint1
onready var j2 := $Joint2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	_draw()

func _draw():
	draw_line(j1.position, j2.position, Color.red)
