extends Control


export (PackedScene) var headWidg
export (PackedScene) var segmWidg
export (PackedScene) var tailWidg
export (int) var hseperation := 0
export (int) var amplitude := 10

var yoff := 0
var tail
var head
var body := []


func _ready():
	#if Engine.editor_hint:
	_test_grow()


func _on_Segment_took_damage(position, segment):
	pass


func _on_Segment_died(position, segment):
	pass


func _on_Worm_size_changed(to: int):
	if head == null:
		_init_health_bar(to)
	elif len(body) < to:
		_grow_to_size(to)
	elif len(body) > to:
		_shrink_to_size(to)


func _shrink_to_size(to: int):
	var by: int = len(body) - to
	if by <= 0: return

	var seg
	# n-1, n-by-2, by+1 removed
	var size := len(body)
	for i in range(size - 1, size - by - 2, -1):
		seg = body[i]
		body.remove(i)
		remove_child(seg)
		seg.queue_free()
	# add head back in
	head = headWidg.instance()
	body.append(head)
	add_child(head)
	_position_segments()
	

func _grow_to_size(to: int):
	var by: int = to - len(body)
	if by <= 0: return

	var seg
	var curr_length := len(body)
	# replace current head
	body.remove(curr_length - 1)
	remove_child(head)
	head.queue_free()
	# add segments
	for i in range(curr_length - 1, curr_length + by - 1):
		seg = segmWidg.instance()
		body.append(seg)
		add_child(seg)
	# add new tail
	head = headWidg.instance()
	body.append(head)
	add_child(head)

	_position_segments()


func _init_health_bar(size: int):
	tail = tailWidg.instance()
	body.append(tail)
	for i in range(1, size - 1):
		var segm = segmWidg.instance()
		body.append(segm)
	head = headWidg.instance()
	body.append(head)
	
	var xoff := 0
	for seg in body:
		add_child(seg)
		if seg == tail:
			yoff = 25 + amplitude
	
	_position_segments()


func _position_segments():
	var xoff := 0
	for seg in body:
		seg.rect_position.x = xoff
		seg.rect_position.y = yoff - seg.rect_size.y / 2 
		xoff += seg.rect_size.x + hseperation 


func _process(_delta):
	var seg
	var offset
	var msec = OS.get_ticks_msec() / 500.0
	var sqr_size := float(min(get_child_count(), 8))
	var pow_term := pow(1.5, -(sqr_size - 3))
	for i in range(body.size()):
		seg = body[i]
		offset = yoff - seg.rect_size.y * 0.5 + sin(
			(msec + i * 0.5) * 4 *  pow_term
		) * amplitude
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

