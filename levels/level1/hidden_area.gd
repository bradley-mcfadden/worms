extends Node2D


func _on_BreakableWall2_broke(is_broken: bool) -> void:
	# print("Breakable wall broke! ", str(is_broken))
	self.visible = !is_broken
