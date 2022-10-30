
#
# spawn_kinematic.gd is the player class.
# It takes care of adding the segments to create the worm,
# managing the current list of segments, and controlling
# the worm movement.
#

extends Position2D

const MAX_SPEED := 400
const ACC := 20

enum SegmentState { ALIVE, DEAD }

# Emitted when a segment is created or dies
signal segment_changed(segment, state) # Node, SegmentState/int
# Emitted when the player wants to switch layers
signal switch_layer_pressed(new_layer, node) # int, Node
# Emitted when the player wants to peek at a layer
signal layer_visibility_changed(layer, is_visible) # int, bool
# Emitted when the player is killed
signal died(from, overkill) # Node, bool
# Emitted when a segment takes damage
signal segment_took_damage(position, segment) # int, Node
# Emitted when the number of segments in the body changes
signal size_changed(to) # int
# Emitted when the abilities UI may be initialized
signal abilities_ready(abilities) # Array[Ability]
# Emitted when an ability state is changed
signal ability_is_ready_changed(ability, is_ready) # Ability, bool
# Emitted when an ability with a cd's state changes
signal ability_is_ready_changed_cd(ability, is_ready, duration) # Ability, bool, float
# Emitted to signal if the player is near death
signal health_state_changed(is_low) # bool
# Emitted if the player produces a noise that enemies should react to
#warning-ignore:unused-signal
signal noise_produced(position, audible_radius) # Vector2, float

# fill this with camera2D node
export(PackedScene) var camera
export(PackedScene) var Segment
export(PackedScene) var Head
export(PackedScene) var Tail
export(int) var segment_number := 30
# difference between two segments' theta along sin curve, controls oscillation
export(float) var tdelta := 0.75
export(int) var max_speed := MAX_SPEED
export(int) var acceleration := ACC
export(float) var speed_decay := 0.95
export(int) var layer := 0
export(int) var minimum_length := 5
export(int) var num_segment_for_low_health := minimum_length + 10

var dead := false
var body := []
var heading: float = 0
# If initial velocity is not nonzero, then the worm collapses to a single point
var vel := Vector2(0.001, 0)
# base is default distance betveen joints.
var base: int = 40
# Track a running total of joint positions in the worm during initialization/movement
var j1 := Vector2()
# Counter keeping track of variable used for finding segment horizontal offset 
var osc_counter := 0.0
# Pointer to head
var head
# Pointer to tail
var tail
# Camera
var wide_camera: Camera2D
# Iterator over body
var iter: Object # Iterator
var free_later_list := []
var start_transform: Transform2D
var start_layer: int
var is_switch_depth := false
var background: BackgroundNoise
var active_controller: WormController

onready var body_mut := Mutex.new()
onready var dirt_color: Color


func _ready() -> void:
# This loop will set segment's properties.
# Every segment can have different base, scale...
	for i in range(segment_number):
		var segment
		if i == 0:
			segment = Head.instance()
			head = segment
			head.connect("interactible_bitten", $AbilitiesContainer/Bite, "_on_interactible_bitten")
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
	# Reverse the draw order of segments
	for i in body:
		move_child(i, 0)
	if camera:
		wide_camera = camera.instance()
		add_child(wide_camera)
		call_deferred("scale_camera")

	# Connect abilities to our ability signals so they work with abilities bar
	var abilities := $AbilitiesContainer.get_children()
	for ability in abilities:
		ability.parent = self
		if not ability.is_connected("is_ready_changed", self, "_on_ability_is_ready_changed"):
			ability.connect("is_ready_changed", self, "_on_ability_is_ready_changed")
		if not ability.is_connected("is_ready_changed_cd", self, "_on_ability_is_ready_changed_cd"):
			ability.connect("is_ready_changed_cd", self, "_on_ability_is_ready_changed_cd")
		ability.setup()
	emit_signal("abilities_ready", abilities)
	start_layer = layer
	emit_signal("size_changed", len(body))
	emit_signal("health_state_changed", false)

	# Connect the controller so we can query about what we should do.
	_init_controller()


func emit_signals_first_time() -> void:
#
# emit_signals_first_time - Call me to re-emit signals from _ready().
#
	for segm in body:
		emit_signal("segment_changed", segm, SegmentState.ALIVE)
	emit_signal("abilities_ready", $AbilitiesContainer.get_children())
	emit_signal("size_changed", len(body))
	emit_signal("health_state_changed", false)


func _init_controller() -> void:
	for controller in [$CursorController, $InputController]:
		controller.set_physics_process(false)
	var scheme: String = Configuration.sections["controls"]["current_scheme"]
	match scheme:
		"keyboard":
			active_controller = $InputController
		"mouse_keyboard":
			active_controller = $CursorController
			$CursorController.following = head
	active_controller.set_physics_process(true)
	active_controller.set_abilities_count(len($AbilitiesContainer.get_children()))


func reset() -> void:
#
# reset
# Reset the worm back to its initial state.
# 
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
		if segment != null:
			segment.queue_free()
	body.clear()
	_ready()


func _draw() -> void:
	pass
	#for segment in body:
	#	draw_line(segment.j1, segment.j2, Color.red)


func _process(_delta: float) -> void:
	update()
	update_camera_position()


func update_camera_position() -> void:
#
# update_camera_position
# Recenter the camera so it follows the centroid the worm.
#
	var sum := Vector2.ZERO
	if (len(body) == 0) or !is_alive(): return
	var count := 0
	for child in get_children():
		if child is KinematicBody2D and child.is_alive():
			sum += child.position
			count += 1

	if count == 0: return
	var avg = sum / count
	wide_camera.position = avg

	if background:
		background.set_noise_offset(avg)


func _physics_process(delta: float) -> void:
	_control(delta)
	# Move each segment to its proper position
	if vel.length() > 0:
		var vel_ = vel.rotated(heading) * delta
		var ivel = Vector2(vel.y, vel.x).normalized()

		var i = osc_counter
		var speed_rate = vel.x / max_speed
		var slither_sound = $Sounds/Slither
		body_mut.lock()
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
		body_mut.unlock()

		osc_counter += 0.2
	# Free any dead segments
	for _i in range(len(free_later_list)):
		var _node = free_later_list.pop_back()
		_node.queue_free()
		var idx = body.find(_node)
		if idx != -1: body.remove(idx)


func _control(delta: float) -> void:
#
# _control
# Query the controller for what actions are currently happening, then
# adjust the worm's state to account for that.
# delta - Time since last physics frame.
#
	if not is_alive():
		return
	if active_controller.is_action_pressed("move_forward"):
		vel.x += acceleration
		vel.x = vel.x if vel.x <= max_speed else vel.x * speed_decay
	else:
		vel *= speed_decay

	if active_controller.is_action_pressed("move_left"):
		heading -= PI * delta * 3
	elif active_controller.is_action_pressed("move_right"):
		heading += PI * delta * 3
	if !is_switch_depth:
		if active_controller.is_action_just_pressed("peek_layer_down"):
			emit_signal("layer_visibility_changed", layer + 1, true)
		elif active_controller.is_action_just_released("peek_layer_down"):
			emit_signal("layer_visibility_changed", layer + 1, false)
		elif active_controller.is_action_just_pressed("peek_layer_up"):
			emit_signal("layer_visibility_changed", layer - 1, true)
		elif active_controller.is_action_just_released("peek_layer_up"):
			emit_signal("layer_visibility_changed", layer - 1, false)
		elif active_controller.is_action_just_pressed("layer_down"):
			if not head.overlaps_below():
				$Sounds/ChangeLayerDown.play()
				emit_signal("switch_layer_pressed", layer + 1, self)
		elif active_controller.is_action_just_pressed("layer_up"):
			if not head.overlaps_above():
				$Sounds/ChangeLayerUp.play()
				emit_signal("switch_layer_pressed", layer - 1, self)
	for i in range(0, $AbilitiesContainer.get_child_count()):
		var ability = $AbilitiesContainer.get_child(i)
		if (ability != null and ability.is_ready and active_controller.is_action_just_pressed("ability" + str(i + 1))):
			ability.invoke()


func set_active_controller(controller: WormController) -> void:
#
# set_active_controller
# Change the controller responsible for telling the worm what to do.
# controller - WormController implementation to be used, now.
#
	active_controller = controller


func add_segment() -> void:
#
# add_segment
# Add a segment to the worm's body.
# This is a complicated operation, because the end of the worm
# is drawn differently. So, we need to get rid of the old tail,
# add a new segment, and add a new tail.
#
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

	new_seg.layer = head.get_layer()
	new_tail.layer = head.get_layer()
	new_seg.position = old_tail.position
	new_tail.position = old_tail.position

	old_tail.hide()
	old_tail.disconnect("segment_died", self, "_on_segment_died")
	old_tail.take_damage(1000, null)

	new_seg.connect("segment_died", self, "_on_segment_died")
	new_seg.connect("took_damage", self, "_on_segment_took_damage")

	new_tail.connect("segment_died", self, "_on_segment_died")
	new_tail.connect("took_damage", self, "_on_segment_took_damage")

	new_seg.set_dirt_color(dirt_color)
	new_tail.set_dirt_color(dirt_color)

	emit_signal("segment_changed", old_tail, SegmentState.DEAD)
	emit_signal("segment_changed", new_seg, SegmentState.ALIVE)
	emit_signal("segment_changed", new_tail, SegmentState.ALIVE)
	emit_signal("size_changed", len(body))
	if len(body) >= num_segment_for_low_health:
		emit_signal("health_state_changed", false)

	scale_camera()


func scale_segments(factor: float) -> void:
#
# scale_segments
# Use to multiply the scale vector of each segment by factor.
# factor - Scalar amount to multiply scale vector by.
#
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


func split() -> Array:
#
# split
# NOTE: This is not used anywhere in the game currently. 
# Split the worm at its 5th segment.
# return - An array of the split off parts.
#
	var destroyed_parts = []
	for _i in range(5):
		var _tail = body.pop_back()
		destroyed_parts.append(_tail)
		emit_signal("segment_changed", _tail, SegmentState.DEAD)

	return destroyed_parts


func apply_boost_speed() -> void:
#
# apply_boost_speed
# NOTE: Need to check if this is still being used.
# Code that gives the worm a temporary speed boost.
#
	max_speed *= 2
	acceleration *= 2
	$BoostTimer.start()


func reset_boost_speed() -> void:
#
# reset_boost_speed
# NOTE: Need to check if this is still being used.
# Code that resets the worm's temporary speed boost.
#
	max_speed = int(0.5 * max_speed)
	acceleration = int(0.5 * max_speed)


func scale_camera():
	if camera:
		var new_zoom = Vector2(0.1, 0.1) * len(body)
		new_zoom.x = clamp(new_zoom.x, 2.5, 3.4)
		new_zoom.y = clamp(new_zoom.y, 2.5, 3.4)
		if wide_camera.has_method("zoom_to"):
			wide_camera.zoom_to(new_zoom)


func get_entity_positions() -> Array:
#
# get_entity_positions
# TODO: Rename this to something like "get_body_parts"
# Poorly named function that actually returns the individual
# body parts of the worm.
# return - Each segment of the worm.
#
	var pts := []
	for x in range(get_child_count()-1, -1, -1):
		var child = get_child(x)
		if child is KinematicBody2D:
			pts.append(child)
	return pts


func get_layer() -> int:
	return head.get_layer()


func set_active(is_active: bool) -> void:
	for segment in body:
		segment.set_modulate(Color(1, 1, 1, 1) if is_active else Color(1, 1, 1, 0.3))


func set_layer(new_layer: int) -> void:
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
# 
# get_head
# NOTE: This function does not need to exist.
# return - The first body part, or the head.
#
	return head


func is_alive() -> bool:
#
# is_alive
# NOTE: Could be replaced by calls to `not dead`
# return - Whether the player could be considered alive.
#
	return not dead


func _on_DiveTimer_timeout():
	var segment = iter.next()
	if segment != null:
		segment.set_layer(layer)
		$DiveTimer.start()
		segment.fade_in($DiveTimer.wait_time)
	else:
		is_switch_depth = false


func _on_ability_is_ready_changed(ability: Ability, is_ready: bool) -> void:
	emit_signal("ability_is_ready_changed", ability, is_ready)


func _on_ability_is_ready_changed_cd(ability: Ability, is_ready: bool, duration: float) -> void:
	emit_signal("ability_is_ready_changed_cd", ability, is_ready, duration)


func _on_head_animation_changed(_from: String, _to: String) -> void:
	#$AbilitiesContainer/Bite.set_is_ready(to == "idle")
	pass


func _on_segment_died(segment: Node, from: Node, overkill: bool) -> void:
	body_mut.lock()
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
			if active_controller == $CursorController:
				$CursorController.following = null
			dead = true
			emit_signal("died", from, overkill)
		elif (len(body) < num_segment_for_low_health):
			emit_signal("health_state_changed", true)
	body_mut.unlock()


func _play_death_sound(segment: Node) -> void:
	if segment == head:
		$Sounds/HeadDeath.play()
	else:
		$Sounds/SegmentDeath.play()


func _on_segment_took_damage(segment: Node, hurt: bool = false) -> void:
	if hurt: $Sounds/SegmentTakeDamage.play()
	var idx = body.find(segment)
	emit_signal("segment_took_damage", idx, segment)

	if segment == head: 
		var ratio = float(segment.health / segment.start_health)
		if ratio < 0.5:
			emit_signal("health_state_changed", true)


func _on_unpaused() -> void:
	_init_controller()


func set_dirt_color(color: Color) -> void:
	for segment in body:
		segment.set_dirt_color(color)
	dirt_color = color