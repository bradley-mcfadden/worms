extends Ability

func _ready():
	is_ready = true
	randomize()


func invoke():
	if not is_ready:
		return
	is_ready = false
	var head = parent.get_head()
	var player = head.get_animation_player()
	player.play("mouth_open_wide")
	_play_roar_sound()
	emit_signal("is_ready_changed", self, false)


func set_is_ready(_is_ready: bool):
	if _is_ready != self.is_ready:
		emit_signal("is_ready_changed", self, _is_ready)
	self.is_ready = _is_ready


func _play_roar_sound():
	var i := int(rand_range(0, $RoarSounds.get_child_count() - 0.01))
	$RoarSounds.get_child(i).play()
