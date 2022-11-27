shader_type canvas_item;

uniform float target_hue;
uniform float replace_hue;
uniform float threshold;
uniform float sat_adjust = 1.0;


vec3 rgb2hsb( in vec3 c ){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
    // color of the fragment
    vec4 texcolor = texture(TEXTURE, UV);
    // color as hsb
    vec3 hsb_t = rgb2hsb(texcolor.rgb);
    float diff = hsb_t.x - target_hue;
    vec4 repcolor = vec4(hsb2rgb(vec3(mod(replace_hue + diff, 1.0), sat_adjust * hsb_t.g, hsb_t.b)), texcolor.a);
    // COLOR = mix(repcolor, texcolor, step_all(threshold, diff));
    COLOR = mix(repcolor, texcolor, step(threshold, abs(diff)));
}