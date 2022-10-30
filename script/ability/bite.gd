# bite.gd
# Bite is an ability that is a short range melee attack.
# It has two parts, the wind up, and the snap
# The first press causes the windup, then after a timer or
# the second press, a hitbox will appear at the player mouth.
extends Ability

const CHOMP_TO_IDLE := "chomp_to_idle"
const MOUTH_CHOMP := "mouth_chomp"
const MOUTH_OPEN_WIDE := "mouth_open_wide"

onready var n_invoke_called := 0
onready var anim_player: AnimationPlayer = null


func setup() -> void:
# Connect some callbacks to the animation player
	is_ready = true
	randomize()
	var head = parent.get_head()
	anim_player = head.get_animation_player()
	var _connected = anim_player.connect("animation_finished", self, "_on_animation_finished")
	_connected = anim_player.connect("animation_changed", self, "_on_animation_changed")


func invoke() -> void:
# State machine that executes wind up and snap
	if not is_ready:
		return
	n_invoke_called += 1
	emit_signal("is_ready_changed", self, false)
	is_ready = false

	if n_invoke_called == 1:
		wind_up()
	elif n_invoke_called == 2:
		bite()


func wind_up() -> void:
# Play mouth opening animation, sound, and emit signal
	if anim_player == null: return
	anim_player.play(MOUTH_OPEN_WIDE)
	_play_roar_sound()
	#emit_signal("is_ready_changed", self, false)
	$Timer.start()


func bite() -> void:
# Play mouth biting animation
	if anim_player == null: return
	anim_player.playback_speed = 2.0
	anim_player.play(MOUTH_CHOMP)
	# emit_signal("is_ready_changed", self, false)
	yield(anim_player, "animation_changed")
	anim_player.playback_speed = 1.0


func _on_Timer_timeout():
	if n_invoke_called:
		if not anim_player == null and parent.is_alive():
			anim_player.call_deferred("play", MOUTH_CHOMP)


func set_is_ready(_is_ready: bool) -> void:
# Change ready state
	if _is_ready != self.is_ready:
		emit_signal("is_ready_changed", self, _is_ready)
	self.is_ready = _is_ready


func _play_roar_sound() -> void:
# Play random roar sound, and emit a noise signal 
	var i := int(rand_range(0, $RoarSounds.get_child_count() - 0.01))
	$RoarSounds.get_child(i).play()
	var head = parent.get_head()
	var worm = head.get_parent()
	worm.emit_signal("noise_produced", head.global_position, 500)


func _on_animation_finished(name: String) -> void:
	if name == MOUTH_OPEN_WIDE:
		is_ready = true
		#emit_signal("is_ready_changed", self, true)


func _on_animation_changed(from: String, to: String) -> void:
	if from == MOUTH_CHOMP and to == CHOMP_TO_IDLE:
		is_ready = true
		emit_signal("is_ready_changed", self, true)
		n_invoke_called = 0
		$Timer.stop()


func _on_interactible_bitten() -> void:
	n_invoke_called = 2
	bite()
	$Timer.stop()
