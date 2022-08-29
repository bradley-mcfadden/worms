shader_type canvas_item;

uniform vec4 fill_color: hint_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 texcolor = texture(TEXTURE, UV);
	vec2 uv = vec2(0.5) - UV;
	float x = 2.75 * TIME;
	float trig = max(sin(x), cos(x));
	float t = trig * 0.5 + 0.5;
	COLOR = mix(texcolor, fill_color, max((length(uv) - pow(0.5, 2)) * t, 0));
	
}