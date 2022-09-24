extends Ability

const CHOMP_TO_IDLE := "chomp_to_idle"
const MOUTH_CHOMP := "mouth_chomp"
const MOUTH_OPEN_WIDE := "mouth_open_wide"

onready var n_invoke_called := 0
onready var anim_player: AnimationPlayer = null


func setup():
	is_ready = true
	randomize()
	var head = parent.get_head()
	anim_player = head.get_animation_player()
	var _connected = anim_player.connect("animation_finished", self, "_on_animation_finished")
	_connected = anim_player.connect("animation_changed", self, "_on_animation_changed")


func invoke():
	if not is_ready:
		return
	n_invoke_called += 1
	is_ready = false

	# print("Bite invoke ", n_invoke_called)
	if n_invoke_called == 1:
		anim_player.play(MOUTH_OPEN_WIDE)
		_play_roar_sound()
		emit_signal("is_ready_changed", self, false)
	elif n_invoke_called == 2:
		anim_player.play(MOUTH_CHOMP)
		emit_signal("is_ready_changed", self, false)


func set_is_ready(_is_ready: bool):
	if _is_ready != self.is_ready:
		emit_signal("is_ready_changed", self, _is_ready)
	self.is_ready = _is_ready


func _play_roar_sound():
	var i := int(rand_range(0, $RoarSounds.get_child_count() - 0.01))
	$RoarSounds.get_child(i).play()
	var head = parent.get_head()
	var worm = head.get_parent()
	worm.emit_signal("noise_produced", head.global_position, 500)


func _on_animation_finished(name: String):
	# print("Finished animation ", name)
	if name == MOUTH_OPEN_WIDE:
		is_ready = true
		emit_signal("is_ready_changed", self, true)


func _on_animation_changed(from: String, to: String):
	# print("Switched from ", from, " to ", to)
	if from == MOUTH_CHOMP and to == CHOMP_TO_IDLE:
		is_ready = true
		emit_signal("is_ready_changed", self, true)
		n_invoke_called = 0
