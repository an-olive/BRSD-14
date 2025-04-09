shader_type particles;

void start() {
	// Called when a particle is spawned.
	COLOR = vec4(1, 0, 0, 1);
	//TRANSFORM = mat4(vec4(1.0, 0.0, 0.0, 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(0.0, 0.0, 0.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0)) * EMISSION_TRANSFORM;
	TRANSFORM = EMISSION_TRANSFORM;
	VELOCITY = vec3(0, 0, 0);
}

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
	//TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	//TRANSFORM[3].xy += vec2(1, 0) * DELTA;
	VELOCITY += vec3(0, 10, 0) * DELTA;
}
