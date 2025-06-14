shader_type canvas_item;

uniform bool is_valid = true;
uniform float lighten = 0.25;
uniform float invalid_red = 2.0;
uniform float opacity = 0.75;

void fragment() {
	COLOR.rgb = vec3(1, 1, 1) - (vec3(1, 1, 1) - COLOR.rgb) * (1.0 - lighten);
	if (!is_valid) {
		COLOR.r = min(COLOR.r * invalid_red, 1.0);
	}
	COLOR.a *= opacity;
}