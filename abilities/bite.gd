extends Ability

var is_ready := true


func invoke():
	if not is_ready:
		return
	is_ready = false
	var player = parent.get_head().get_animation_player()
	player.play("mouth_open_wide")
	emit_signal("is_ready_changed", self, false)


func set_is_ready(_is_ready: bool):
	if _is_ready != self.is_ready:
		emit_signal("is_ready_changed", self, _is_ready)
	self.is_ready = _is_ready
