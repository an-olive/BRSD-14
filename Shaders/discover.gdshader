shader_type canvas_item;

uniform vec2 pos = vec2(0, 0);
uniform float radius = 50.0;
//uniform vec4 

// clamped lerp
float clerp(float a, float b, float t) {
	return clamp(a + (b - a) * t, min(a, b), max(a, b));
}

void fragment() {
	float distanceFromPos = distance(UV.xy / TEXTURE_PIXEL_SIZE.xy, pos);
	//COLOR.rgba = vec4(0, 0, 0, 1);
	//COLOR.b = distanceFromPos / radius;
	//COLOR.a = 1.0;
	COLOR.a = clerp(COLOR.a, 0.0 , distanceFromPos / radius);
}
