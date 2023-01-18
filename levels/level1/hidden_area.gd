extends Node2D


func _on_BreakableWall2_broke(is_broken: bool) -> void:
	# print("Breakable wall broke! ", str(is_broken))
	if is_broken:
		$Tween.interpolate_property(self, "modulate", null, Color.transparent, 1.0)
		$Tween.start()
		$Revealed.play()
		yield($Tween, "tween_completed")
	self.visible = !is_broken
