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
	_test()


func _on_Segment_took_damage(position, segment):
	pass


func _on_Segment_died(position, segment):
	pass


func _on_Worm_size_changed(to:int):
	if head == null:
		_init_health_bar(to)
	elif len(body) < to:
		pass
	elif len(body) > to:
		pass


func _init_health_bar(size:int):
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
 

func _test():
	_init_health_bar(20)
