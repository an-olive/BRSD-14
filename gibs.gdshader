shader_type particles;

uniform vec2 bounds = vec2(200, 200);
uniform float forceMultiplier = 100000;
uniform float destructionRadius = 4.0;
uniform float wallElasticity = 0.5;

void start() {
	// Called when a particle is spawned.
	COLOR = vec4(1, 0, 0, 1);
	//TRANSFORM = mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(0.0, 0.0, 0.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0)) * EMISSION_TRANSFORM;
	TRANSFORM = EMISSION_TRANSFORM;
	TRANSFORM[3].xy = vec2(1, 1);
	VELOCITY = vec3(abs(cos(TIME)), abs(sin(TIME)), 0) * 30.0;
}

void process() {
	vec2 relativeToCenter = bounds / 2.0 - TRANSFORM[3].xy;
	float distanceFromCenter = sqrt(pow(relativeToCenter.x, 2.0) + pow(relativeToCenter.y, 2.0));
	ACTIVE = distanceFromCenter > destructionRadius;
	float force = (1.0 / pow(distanceFromCenter, 2.0)) * forceMultiplier;
	float angle = atan(relativeToCenter.y, relativeToCenter.x);
	//TRANSFORM[3].x = distanceFromCenter + 1.0;
	VELOCITY += vec3(cos(angle), sin(angle), 0) * force * DELTA;
	COLOR = vec4(1, 0, 0, 1);
	if (TRANSFORM[3].x < 0.0 || TRANSFORM[3].x > bounds.x) {
		TRANSFORM[3].x = clamp(TRANSFORM[3].x, 0.0, bounds.x);
		VELOCITY.x *= -wallElasticity;
	}
	if (TRANSFORM[3].y < 0.0 || TRANSFORM[3].y > bounds.y) {
		TRANSFORM[3].y = clamp(TRANSFORM[3].y, 0.0, bounds.y);
		VELOCITY.y *= -wallElasticity;
	}
}
