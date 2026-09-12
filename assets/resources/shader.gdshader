shader_type spatial;

uniform vec4 water_color : source_color = vec4(0.05, 0.45, 0.65, 0.75);
uniform float wave_strength = 0.08;
uniform float wave_speed = 1.5;
uniform float wave_scale = 2.5;

void vertex() {
    float wave1 = sin(VERTEX.x * wave_scale + TIME * wave_speed);
    float wave2 = cos(VERTEX.z * wave_scale * 1.3 + TIME * wave_speed * 0.8);

    VERTEX.y += (wave1 + wave2) * wave_strength;
}

void fragment() {
    ALBEDO = water_color.rgb;
    ROUGHNESS = 0.1;
    METALLIC = 0.0;
    ALPHA = water_color.a;
}

