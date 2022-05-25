extends Node2D


const SPEED = 50


func _process(_delta):
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position.y -= SPEED * _delta
	elif Input.is_action_pressed("ui_down"):
		$Camera2D.position.y += SPEED * _delta
	elif Input.is_action_pressed("ui_right"):
		$Camera2D.position.x += SPEED * _delta
	elif Input.is_action_pressed("ui_left"):
		$Camera2D.position.x -= SPEED * _delta
