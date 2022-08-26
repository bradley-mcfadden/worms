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
	pass


# set the icon at position to the correct fill level
# based on segment remaining health
func _on_Segment_took_damage(position: int, segment):
	if !_in_bounds(position):
		return
	print("segment at ", position, " took damage")
	body[position].set_proportion(float(segment.health) / segment.start_health)


# bounds check pos against len of body
func _in_bounds(pos: int) -> bool:
	return pos >= 0 && pos < len(body)


# update number of icons to size "to"
func _on_Worm_size_changed(to: int):
	print("size changed", to)
	if head == null:
		_init_health_bar(to)
	elif len(body) < to:
		_grow_to_size(to)
	elif len(body) > to:
		_shrink_to_size(to)


func _shrink_to_size(to: int):
	var by: int = len(body) - to
	if by <= 0:
		return

	var seg
	# n-1, n-by-2, by+1 removed
	var size := len(body)
	for i in range(size - 1, size - by - 2, -1):
		seg = body[i]
		body.remove(i)
		remove_child(seg)
		seg.queue_free()
	# add head back in
	head = head_widg.instance()
	body.append(head)
	add_child(head)
	_position_segments()


func _grow_to_size(to: int):
	var by: int = to - len(body)
	if by <= 0:
		return

	var seg
	var curr_length := len(body)
	# replace current head
	body.remove(curr_length - 1)
	remove_child(head)
	head.queue_free()
	# add segments
	for _i in range(curr_length - 1, curr_length + by - 1):
		seg = segm_widg.instance()
		body.append(seg)
		add_child(seg)
	# add new tail
	head = head_widg.instance()
	body.append(head)
	add_child(head)

	_position_segments()


func _init_health_bar(size: int):
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
	yield(get_tree().create_timer(4.0), "timeout")
	_shrink_to_size(10)


func _test_grow():
	_init_health_bar(10)
	yield(get_tree().create_timer(4.0), "timeout")
	_grow_to_size(20)


func _test_take_damage():
	_init_health_bar(10)
	yield(get_tree().create_timer(4.0), "timeout")
	_on_Segment_took_damage(5, DummySegment.new())


class DummySegment:
	var health := 50
	var start_health := 100
