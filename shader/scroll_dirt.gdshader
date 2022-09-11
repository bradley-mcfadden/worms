shader_type canvas_item;

// Scroll a texture with time, in the x and y axis.

// Speed of scrolling.
uniform vec2 scroll_speed;

void fragment() {
    vec2 shifteduv = UV;
    shifteduv.x += TIME * scroll_speed.x;
	shifteduv.y += TIME * scroll_speed.y;
    vec4 color = texture(TEXTURE, shifteduv);
    COLOR = color;
}