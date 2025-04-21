extends Sprite2D

## Rate of spawned gibs, per second
@export var spawn_rate: float = 30
@export var min_speed: float = 10
@export var max_speed: float = 50

const Gibs = preload("res://gibs.gd")

func _process(_delta: float) -> void:
	var direction = randf() * TAU
	var speed = min_speed + (max_speed - min_speed) * randf()
	var velocity = Vector2(cos(direction) * speed, sin(direction) * speed)
	Gibs.get_instance().spawn_gib(position + Vector2(9, 9), velocity, 0)
