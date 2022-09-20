# health_bar.gd
# author: Bradley McFadden
# date: 2022-08-21
# brief: Manages a list of icons that oscillate and display worm health.
extends Control

export(PackedScene) var head_widg
export(PackedScene) var segm_widg
export(PackedScene) var tail_widg
export(int) var hseperation := 0
export(int) var amplitude := 10

var yoff := 0
var tail
var head
var body := []


func _ready():
	#_test_shrink()
	pass


# set the icon at position to the correct fill level
# based on segment remaining health
func _on_Segment_took_damage(position: int, segment):
	if !_in_bounds(position):
		return
	print("segment at ", position, " took damage")
	body[len(body)-position-1].set_proportion(float(segment.health) / segment.start_health)


# bounds check pos against len of body
func _in_bounds(pos: int) -> bool:
	return pos >= 0 && pos < len(body)


# update number of icons to size "to"
func _on_Worm_size_changed(to: int):
	if to < 0: return
	if head == null:
		_init_health_bar(to)
	elif len(body) < to:
		_grow_to_size(to)
	elif len(body) > to:
		_shrink_to_size(to)


func _shrink_to_size(to: int):
	var by: int = len(body) - to
	if by <= 0 or to < 0:
		return

	print("_shrink_to_size ", to, " removing ", by)

	var seg
	# n-1, n-by-2, by+1 removed
	for i in range(by-1, -1, -1):
		seg = body[i]
		body.remove(i)
		remove_child(seg)
		seg.queue_free()
		print(str(seg.proportion), " at ", i)
	if to != 0:
		var new_tail = tail_widg.instance()
		new_tail.set_proportion(tail.proportion)
		add_child(new_tail)
		var new_body := [new_tail]
		new_body.append_array(body)
		body = new_body
		tail = new_tail
	else:
		for segm in body:
			remove_child(segm)
			segm.queue_free()
		body.clear()
		tail = null
		head = null
		hide()

	_reorder_children()
	_position_segments()


func _grow_to_size(to: int):
	var by: int = to - len(body)
	if by <= 0:
		return

	var seg
	# add segments
	var new_body := []
	var new_tail = tail_widg.instance()
	new_body.append(new_tail)
	add_child(new_tail)
	for _i in range(by):
		seg = segm_widg.instance()
		new_body.append(seg)
		add_child(seg)
	tail = new_tail
	var old_tail = body.pop_front()
	var replacement_seg = new_body.back()
	replacement_seg.set_proportion(old_tail.proportion)
	remove_child(old_tail)
	old_tail.queue_free()
	new_body.append_array(body)
	body = new_body

	_reorder_children()
	_position_segments()


func _init_health_bar(size: int):
	show()
	tail = tail_widg.instance()
	body.append(tail)
	for _i in range(1, size - 1):
		var segm = segm_widg.instance()
		body.append(segm)
	head = head_widg.instance()
	body.append(head)

	for seg in body:
		add_child(seg)
		if seg == tail:
			yoff = 25 + amplitude

	_position_segments()
	_fill_segments()


func _reorder_children():
	var n := len(body)
	for i in range(n):
		move_child(body[i], i)


func _position_segments():
	var xoff := 0
	for seg in body:
		seg.rect_position.x = xoff
		seg.rect_position.y = yoff - seg.rect_size.y / 2
		xoff += seg.rect_size.x + hseperation


func _fill_segments():
	for seg in body:
		seg.set_proportion()


func _process(_delta):
	var seg
	var offset
	var msec = OS.get_ticks_msec() / 500.0
	var sqr_size := float(min(get_child_count(), 8))
	var pow_term := pow(1.5, -(sqr_size - 3))
	for i in range(body.size()):
		seg = body[i]
		offset = yoff - seg.rect_size.y * 0.5 + sin((msec + i * 0.5) * 4 * pow_term) * amplitude
		seg.rect_position.y = offset


func _test_init_health_bar():
	_init_health_bar(20)


func _test_shrink():
	_init_health_bar(20)
	var dummy0 := DummySegment.new()
	dummy0.health = 75
	var dummy1 := DummySegment.new()
	dummy1.health = 25
	_on_Segment_took_damage(0, dummy0)
	_on_Segment_took_damage(5, dummy0)
	_on_Segment_took_damage(19, dummy1)
	
	_on_Segment_took_damage(15, dummy1)
	yield(get_tree().create_timer(4.0), "timeout")
	_shrink_to_size(0)


func _test_grow():
	_init_health_bar(10)
	var dummy0 := DummySegment.new()
	dummy0.health = 75
	var dummy1 := DummySegment.new()
	dummy1.health = 25
	_on_Segment_took_damage(5, dummy0)
	_on_Segment_took_damage(9, dummy1)
	yield(get_tree().create_timer(4.0), "timeout")
	_grow_to_size(20)


func _test_take_damage():
	_init_health_bar(10)
	yield(get_tree().create_timer(4.0), "timeout")
	_on_Segment_took_damage(5, DummySegment.new())


class DummySegment:
	var health := 50
	var start_health := 100
