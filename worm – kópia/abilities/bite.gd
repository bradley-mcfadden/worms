extends Ability

var is_ready := true


func invoke():
	if not is_ready:
		return
	is_ready = false
	var player = parent.get_head().get_animation_player()
	player.play("mouth_open_wide")
	emit_signal("is_ready_changed", self, false)


func set_is_ready(is_ready: bool):
	print("set_is_ready ", self.is_ready, " is_ready ", is_ready)
	if is_ready != self.is_ready:
		emit_signal("is_ready_changed", self, is_ready)
	self.is_ready = is_ready
