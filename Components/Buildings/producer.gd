@tool
extends Building

## Interval between gib spwans, seconds
@export_range(0.001, 1, 0.05, "suffix:s", "or_greater")
var spawn_interval: float = 0.1

@export var enabled: bool = true

@export var min_speed: float = 10
@export var max_speed: float = 50

var gibs_timer = Timer.new()

func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	add_child(gibs_timer)
	gibs_timer.wait_time = spawn_interval
	gibs_timer.one_shot = false
	gibs_timer.connect("timeout", spawn)
	gibs_timer.start()

func spawn() -> void:
	if not enabled:
		return

	var valid_directions = {0: Vector2i(1, 0), 1: Vector2i(0, 1), 2: Vector2i(-1, 0), 3: Vector2i(0, -1)}

	for n in valid_directions.keys():
		if Building.has_collision(location + valid_directions[n]):
			valid_directions.erase(n);

	if valid_directions.is_empty():
		return

	var direction = randf_range(-PI / 4, PI / 4) + valid_directions.keys().pick_random() * PI / 2

	var speed = randf_range(min_speed, max_speed)
	var velocity = Vector2.from_angle(direction) * speed
	Gibs.spawn_gib(position + Vector2(9, 9) + velocity.normalized() * 9, velocity, 0)
