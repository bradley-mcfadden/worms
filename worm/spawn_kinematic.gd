extends Position2D

const MAX_SPEED = 400
const ACC = 20

enum SegmentState { ALIVE, DEAD }

signal segment_changed(segment, state)
signal switch_layer_pressed(new_layer, node)
signal layer_visibility_changed(layer, is_visible)
signal died(from, overkill)
signal segment_took_damage(position, segment)
signal size_changed(to)
signal abilities_ready(abilities)
signal ability_is_ready_changed(ability, is_ready)
signal ability_is_ready_changed_cd(ability, is_ready, duration)
signal health_state_changed(is_low)

# fill this with camera2D node
export(PackedScene) var camera
export(PackedScene) var Segment
export(PackedScene) var Head
export(PackedScene) var Tail
export(int) var segment_number = 30
# difference between two segments' theta along sin curve
# controls oscillation
export(float) var tdelta := 0.75
export(int) var max_speed := MAX_SPEED
export(int) var acceleration := ACC
export(float) var speed_decay := 0.95
export(int) var layer := 0
export(int) var minimum_length := 5
export(int) var num_segment_for_low_health := minimum_length + 10

var dead = false
var body = []
var heading = 0
# If initial velocity is not nonzero, then the worm collapses to a single point
var vel = Vector2(0.001, 0)
# base is default distance betveen joints.
var base = 40
var j1 = Vector2()
var counter = 0
var head
var tail
var wide_camera
var iter
var free_later_list := []
var start_transform: Transform2D
var start_layer: int
var is_switch_depth := false
var background = null


func _ready():
# This loop will set segment's properties.
# Every segment can have different base, scale...
	for i in range(segment_number):
		var segment
		if i == 0:
			segment = Head.instance()
			head = segment
			head.connect("changed_animation", self, "_on_head_animation_changed")
		elif i == segment_number - 1:
			segment = Tail.instance()
			tail = segment
		else:
			segment = Segment.instance()
		add_child(segment)
		segment.base = base
		segment.j1 = j1
		j1 = Vector2(j1.x - base, 0)
		segment.j2 = j1
		body.append(segment)
		emit_signal("segment_changed", segment, SegmentState.ALIVE)
		segment.connect("segment_died", self, "_on_segment_died")
		segment.connect("took_damage", self, "_on_segment_took_damage")
#	this reverses the order of segments in the tree
	for i in body:
		move_child(i, 0)
	if camera:
		wide_camera = camera.instance()
		#scale_camera()
		add_child(wide_camera)
		call_deferred("scale_camera")

	var abilities := $AbilitiesContainer.get_children()
	for ability in abilities:
		ability.parent = self
		if not ability.is_connected("is_ready_changed", self, "_on_ability_is_ready_changed"):
			ability.connect("is_ready_changed", self, "_on_ability_is_ready_changed")
		if not ability.is_connected("is_ready_changed_cd", self, "_on_ability_is_ready_changed_cd"):
			ability.connect("is_ready_changed_cd", self, "_on_ability_is_ready_changed_cd")
	emit_signal("abilities_ready", abilities)
	#start_transform = transform
	start_layer = layer
	emit_signal("size_changed", len(body))
	emit_signal("health_state_changed", false)


func reset():
	dead = false
	# transform = start_transform
	layer = start_layer
	heading = 0
	vel = Vector2(0.001, 0)
	j1 = Vector2()
	if wide_camera:
		remove_child(wide_camera)
		wide_camera.queue_free()
	for segment in body:
		remove_child(segment)
		segment.queue_free()
	body.clear()
	_ready()


func _draw():
	pass
	#for segment in body:
	#	draw_line(segment.j1, segment.j2, Color.red)


func _process(_delta):
	update()
	update_camera_position()


func update_camera_position():
	var sum := Vector2.ZERO
	if (len(body) == 0): return
	for segment in body:
		sum += segment.position

	var avg = sum / len(body)
	wide_camera.position = avg

	if background:
		background.set_noise_offset(avg)


# Do not touch this function.
func _physics_process(delta):
	_control(delta)
	if vel.length() > 0:
		var vel_ = vel.rotated(heading) * delta
		var ivel = Vector2(vel.y, vel.x).normalized()

		var i = counter
		var speed_rate = vel.x / max_speed
		var slither_sound = $Sounds/Slither
		for segment in body:
			vel_ = Vector2(vel_.length(), 0).rotated((segment.j1 - segment.j2).angle_to(vel_))
			segment.theta = i
			var j2 = segment.move(vel_, ivel, delta)
			vel_ = j2
			i += tdelta
			if segment.has_node("DirtMotion"):
				var dirt_node = segment.get_node("DirtMotion")
				dirt_node.speed_scale = speed_rate
			slither_sound.playing = speed_rate > 0.1

		counter += 0.2
	for _i in range(len(free_later_list)):
		var _node = free_later_list.pop_back()
		_node.queue_free()


func _control(delta):
	if not is_alive():
		return
#	This is just example just make sure you dont allow beckvard movement.
	if Input.is_action_pressed("move_forward"):
		vel.x += acceleration
		vel.x = vel.x if vel.x <= max_speed else vel.x * speed_decay
		#print("Moving forward")
	else:
		vel *= speed_decay

	if Input.is_action_pressed("move_left"):
		heading -= PI * delta * 3
	elif Input.is_action_pressed("move_right"):
		heading += PI * delta * 3
	if !is_switch_depth:
		if Input.is_action_just_pressed("peek_layer_up"):
			emit_signal("layer_visibility_changed", layer + 1, true)
		elif Input.is_action_just_released("peek_layer_up"):
			emit_signal("layer_visibility_changed", layer + 1, false)
		elif Input.is_action_just_pressed("peek_layer_down"):
			emit_signal("layer_visibility_changed", layer - 1, true)
		elif Input.is_action_just_released("peek_layer_down"):
			emit_signal("layer_visibility_changed", layer - 1, false)
		elif Input.is_action_just_pressed("layer_down"):
			$Sounds/ChangeLayerDown.play()
			emit_signal("switch_layer_pressed", layer - 1, self)
		elif Input.is_action_just_pressed("layer_up"):
			$Sounds/ChangeLayerUp.play()
			emit_signal("switch_layer_pressed", layer + 1, self)
	for i in range(0, $AbilitiesContainer.get_child_count()):
		var ability = $AbilitiesContainer.get_child(i)
		if Input.is_action_pressed("ability" + str(i + 1)) and ability != null and ability.is_ready:
			ability.invoke()


func add_segment():
	# var old_len := len(body)
	if body.size() == 0: return
	var last2 = body[body.size() - 2]
	var new_seg = Segment.instance()
	new_seg.base = base
	new_seg.j1 = last2.j2
	new_seg.j2 = new_seg.j1 + last2.j2 - last2.j1
	var old_tail = body.pop_back()
	body.append(new_seg)
	add_child(new_seg)
	move_child(new_seg, 0)

	var last = body.back()
	var new_tail = Tail.instance()
	new_tail.base = base
	new_tail.j1 = last.j2
	new_tail.j2 = new_tail.j1 + last.j2 - last.j1
	body.append(new_tail)
	add_child(new_tail)
	move_child(new_tail, 0)

	scale_camera()

	new_seg.layer = head.get_layer()
	new_tail.layer = head.get_layer()

	emit_signal("segment_changed", old_tail, SegmentState.DEAD)
	emit_signal("segment_changed", new_seg, SegmentState.ALIVE)
	emit_signal("segment_changed", new_tail, SegmentState.ALIVE)
	emit_signal("size_changed", len(body))
	if len(body) >= num_segment_for_low_health:
		emit_signal("health_state_changed", false)


func scale_segments(factor):
	var j2 = null
	for segment in body:
		segment.base *= factor
		if segment.has_method("scale_children"):
			segment.scale_children(factor)
		else:
			segment.scale *= factor

		if j2 == null:
			j1 = segment.j1
		else:
			segment.j1 = j2
		segment.j2 = segment.j1 + (segment.j2 - segment.j1) * factor
		j2 = segment.j2


func split():
	var destroyed_parts = []
	for _i in range(5):
		var _tail = body.pop_back()
		destroyed_parts.append(_tail)
		emit_signal("segment_changed", _tail, SegmentState.DEAD)

	return destroyed_parts


func apply_boost_speed():
	max_speed *= 2
	acceleration *= 2
	$BoostTimer.start()


func reset_boost_speed():
	max_speed *= 0.5
	acceleration *= 0.5


func scale_camera():
	if camera:
		var new_zoom = Vector2(0.1, 0.1) * len(body)
		new_zoom.x = max(new_zoom.x, 1.5)
		new_zoom.y = max(new_zoom.y, 1.5)
		# print("changing zoom to ", new_zoom)
		if wide_camera.has_method("zoom_to"):
			wide_camera.zoom_to(new_zoom)
		# else:
		# wide_camera.zoom = new_zoom


func get_entity_positions() -> Array:
	var pts := []
	for segment in body:
		pts.append(segment)

	return pts


func get_layer() -> int:
	return head.get_layer()


func set_active(is_active: bool):
	for segment in body:
		segment.set_modulate(Color(1, 1, 1, 1) if is_active else Color(1, 1, 1, 0.3))
		#segment.visible = true


func set_layer(new_layer: int):
	set_active(false)
	layer = new_layer
	iter = Iterator.new()
	iter.data = body
	$DiveTimer.start()
	is_switch_depth = true


func get_depth_controllers() -> Array:
	var dcs := []
	for segment in body:
		dcs.append_array(segment.get_depth_controllers())
	return dcs


func get_head() -> Node:
	return head


func is_alive() -> bool:
	return not dead


func _on_DiveTimer_timeout():
	var segment = iter.next()
	if segment != null:
		segment.set_layer(layer)
		#segment.visible = true
		$DiveTimer.start()
		segment.fade_in($DiveTimer.wait_time)
	else:
		is_switch_depth = false


func _on_ability_is_ready_changed(ability, is_ready: bool):
	emit_signal("ability_is_ready_changed", ability, is_ready)


func _on_ability_is_ready_changed_cd(ability, is_ready: bool, duration: float):
	emit_signal("ability_is_ready_changed_cd", ability, is_ready, duration)


func _on_head_animation_changed(_from: String, to: String):
	$AbilitiesContainer/Bite.set_is_ready(to == "idle")


func _on_segment_died(segment, from, overkill):
	var idx = body.find(segment)
	if idx != -1:
		for _i in range(len(body) - 1, idx - 1, -1):
			var old_segment = body.pop_back()
			if old_segment == null: break
			old_segment.disconnect("segment_died", self, "_on_segment_died")
			old_segment.take_damage(1000, null)
			yield(get_tree().create_timer(0.1), "timeout")
			emit_signal("segment_changed", old_segment, SegmentState.DEAD)
			emit_signal("size_changed", len(body) - 1)

		if idx != 0 && segment != head:
			call_deferred("add_segment")

		if (len(body) < minimum_length || segment == head) and is_alive():
			dead = true
			emit_signal("died", self, from, overkill)
		elif (len(body) < num_segment_for_low_health):
			emit_signal("health_state_changed", true)


func _play_death_sound(segment: Node):
	if segment == head:
		$Sounds/HeadDeath.play()
	else:
		$Sounds/SegmentDeath.play()


func _on_segment_took_damage(segment):
	$Sounds/SegmentTakeDamage.play()
	var idx = body.find(segment)
	emit_signal("segment_took_damage", idx, segment)

	if segment == head:
		var ratio = float(segment.health / segment.start_health)
		if ratio < 0.5:
			emit_signal("health_state_changed", true)
