#
# rich_text_siny.gd
# Custom rich text effect that causes text to move up and down.
#
tool
class_name RichTextSinY
extends RichTextEffect

var bbcode = "siny"

# syntax [siny period=5.0 offset=10.0 animate=0]
func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var period = char_fx.env.get("period", 5.0)
	var offset = char_fx.env.get("offset", 10.0)
	var animate = char_fx.env.get("animate", 0.0)

	var alpha = sin((char_fx.elapsed_time * animate + char_fx.absolute_index) / period) * offset
	char_fx.offset = Vector2(0, alpha)
	return true
