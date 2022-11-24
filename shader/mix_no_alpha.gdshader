shader_type canvas_item;

uniform sampler2D mix_over;

void fragment() {
    vec4 mcolor = texture(mix_over, UV);
    vec4 tcolor = texture(TEXTURE, UV);

    COLOR = mix(mcolor, tcolor, step(mcolor.a * tcolor.a, 0.0));
}