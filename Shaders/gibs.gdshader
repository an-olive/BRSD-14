shader_type particles;

const vec2 origin = vec2(9, 9);
const vec2 bounds = vec2(378, 342);
const float forceMultiplier = 100000.0;
const float wallElasticity = 0.5;
const float destructionRadius = 9.0;

uniform vec2 velocity = vec2(0, 0);
uniform vec3 color = vec3(1, 0, 0);

void start() {
	TRANSFORM = EMISSION_TRANSFORM;
	VELOCITY = vec3(velocity, 0.0);
	COLOR = vec4(color, 1.0);
}

void process() {
	vec2 relativeToCenter = origin + bounds / 2.0 - TRANSFORM[3].xy;
	float distanceFromCenter = sqrt(pow(relativeToCenter.x, 2.0) + pow(relativeToCenter.y, 2.0));
	ACTIVE = distanceFromCenter > destructionRadius;
	float force = (1.0 / pow(distanceFromCenter, 2.0)) * forceMultiplier;
	float angle = atan(relativeToCenter.y, relativeToCenter.x);
	VELOCITY += vec3(cos(angle), sin(angle), 0) * force * DELTA;

	if (TRANSFORM[3].x < origin.x || TRANSFORM[3].x > origin.x + bounds.x) {
		TRANSFORM[3].x = clamp(TRANSFORM[3].x, origin.x, origin.x + bounds.x);
		VELOCITY.x *= -wallElasticity;
	}
	if (TRANSFORM[3].y < origin.y || TRANSFORM[3].y > origin.y + bounds.y) {
		TRANSFORM[3].y = clamp(TRANSFORM[3].y, origin.y, origin.y + bounds.y);
		VELOCITY.y *= -wallElasticity;
	}
}
