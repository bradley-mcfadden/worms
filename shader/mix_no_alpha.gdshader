shader_type canvas_item;

uniform sampler2D mix_over;
// Decrease me to make mix_over more faint.
uniform float mix_blend: hint_range(0, 1) = 0.3;

void fragment() {
    vec4 mcolor = texture(mix_over, UV);
    vec4 tcolor = texture(TEXTURE, UV);
    float fac = mcolor.a * tcolor.a;
    vec4 color = mix(mcolor, tcolor, step(fac, 0.0));
    vec4 mix_color = vec4(color.rgb * fac, fac);
    COLOR = mix(mix_color, tcolor, 1.0 - mix_blend) * fac + (1.0 - fac) * tcolor;
}