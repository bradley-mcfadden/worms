extends AnimatedSprite 


func _on_PortalMid2_body_entered(body: Node) -> void:
	playing = false


func _on_Area2D_body_entered(body: Node) -> void:
	playing = false