shader_type canvas_item;

uniform float speed = 1.0;
uniform float frequency = 10.0;
uniform vec4 beam_color : source_color = vec4(1.0, 0.2, 0.2, 1.0);
uniform vec4 outline_color : source_color = vec4(1.0, 0.6, 0.6, 1.0);
uniform float thickness : hint_range(0.0, 0.5) = 0.1;

float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    float t = TIME * speed;
    float wave = noise(vec2(UV.x * frequency, t)) * 0.1;
    float dist = abs(UV.y - 0.5 + wave);
    float beam = smoothstep(thickness, thickness * 0.5, dist);
    float outline = smoothstep(thickness * 2.0, thickness, dist) - beam;
    COLOR = beam_color * beam + outline_color * outline;
    COLOR.a = max(beam, outline * 0.5);
}