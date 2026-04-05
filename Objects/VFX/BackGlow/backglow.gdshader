shader_type canvas_item;
render_mode blend_add;

uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.2, 1.0);
uniform float radius = 0.4;

void fragment() {
    float dist = length(UV - vec2(0.5));
    float alpha = smoothstep(radius, 0.0, dist);
    COLOR = vec4(glow_color.rgb, alpha * glow_color.a);
}