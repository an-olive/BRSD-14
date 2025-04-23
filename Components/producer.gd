extends Sprite2D

## Interval between gib spwans, seconds
@export_range(0.001, 1, 0.05, "suffix:s", "or_greater")
var spawn_interval: float = 0.1

@export var min_speed: float = 10
@export var max_speed: float = 50

const Gibs = preload("res://gibs.gd")
var gibs_timer = Timer.new()

func _ready() -> void:
	add_child(gibs_timer)
	gibs_timer.wait_time = spawn_interval
	gibs_timer.one_shot = false
	gibs_timer.connect("timeout", spawn)
	gibs_timer.start()
	
func spawn() -> void:
	var direction = randf_range(0, TAU)
	var speed = randf_range(min_speed, max_speed)
	var velocity = Vector2.from_angle(direction) * speed
	Gibs.get_instance().spawn_gib(position + Vector2(9, 9) + velocity.normalized() * 9, velocity, 0)
