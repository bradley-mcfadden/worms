shader_type canvas_item;

/*
uniform float target_hue;
uniform float replace_hue;
uniform float threshold;
uniform float sat_adjust = 1.0;
*/
uniform vec3 shift_from;
uniform vec3 shift_to;
// Vector holding a threshold for each element of shift from
uniform vec3 threshold;


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
    vec3 texhsb = rgb2hsb(texcolor.rgb);
    float diff1 = abs(texhsb.x - shift_from.x);
    vec4 repcolor1 = vec4(hsb2rgb(vec3(mod(shift_to.x + diff1, 1.0), texhsb.g, texhsb.b)), texcolor.a);
    vec4 mix1 = mix(repcolor1, texcolor, step(threshold.x, diff1));

    texhsb = rgb2hsb(mix1.rgb);
    float diff2 = abs(texhsb.x - shift_from.y);
    vec4 repcolor2 = vec4(hsb2rgb(vec3(mod(shift_to.y + diff2, 1.0), texhsb.g, texhsb.b)), mix1.a);

    vec4 mix2 = mix(repcolor2, mix1, step(threshold.y, diff2));

    texhsb = rgb2hsb(mix2.rgb);
    float diff3 = abs(texhsb.x - shift_from.z);
    vec4 repcolor3 = vec4(hsb2rgb(vec3(mod(shift_to.z + diff3, 1.0), texhsb.g, texhsb.b)), mix2.a);
    vec4 mix3 = mix(repcolor3, mix2, step(threshold.z, diff3));

    COLOR = mix3;
    // COLOR = mix(mix(mix1, mix2, 0.5), mix3, 0.5);
}