# echo_test.gd
# Script for a test scene to ensure that echo.gd follows the screen border.
extends Node2D

const SPEED := 50


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position.y -= SPEED * delta
	elif Input.is_action_pressed("ui_down"):
		$Camera2D.position.y += SPEED * delta
	elif Input.is_action_pressed("ui_right"):
		$Camera2D.position.x += SPEED * delta
	elif Input.is_action_pressed("ui_left"):
		$Camera2D.position.x -= SPEED * delta
