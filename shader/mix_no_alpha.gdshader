shader_type canvas_item;

uniform sampler2D mix_over;

void fragment() {
    vec4 mcolor = texture(mix_over, UV);
    vec4 tcolor = texture(TEXTURE, UV);
    vec3 color = mix(mcolor.rgb, tcolor.rgb, step(mcolor.a * tcolor.a, 0.0));
    COLOR = vec4(color, tcolor.a);
}