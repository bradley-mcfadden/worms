extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SPEED = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(_delta):
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position.y -= SPEED * _delta
	elif Input.is_action_pressed("ui_down"):
		$Camera2D.position.y += SPEED * _delta
	elif Input.is_action_pressed("ui_right"):
		$Camera2D.position.x += SPEED * _delta
	elif Input.is_action_pressed("ui_left"):
		$Camera2D.position.x -= SPEED * _delta
