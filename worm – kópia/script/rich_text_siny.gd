tool
extends RichTextEffect
class_name RichTextSinY

var bbcode = "siny"

# syntax [siny period=5.0 offset=10.0 animate=0]

func _process_custom_fx(char_fx):
	var period = char_fx.env.get("period", 5.0)
	var offset = char_fx.env.get("offset", 10.0)
	var animate = char_fx.env.get("animate", 0.0)

	var alpha = sin((char_fx.elapsed_time * animate + char_fx.absolute_index) / period) * offset
	char_fx.offset = Vector2(0, alpha)
	return true

