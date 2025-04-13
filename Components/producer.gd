extends Sprite2D

## Rate of spawned gibs, per second
@export var spawn_rate: float = 30
@export var min_speed: float = 10
@export var max_speed: float = 50

func _ready() -> void:
	$Gibs.lifetime = 2 * 60 * 60
	$Gibs.amount = $Gibs.lifetime * spawn_rate

func _process(delta: float) -> void:
	var direction = randf() * TAU
	var speed = min_speed + (max_speed - min_speed) * randf()
	var velocity = Vector2(cos(direction) * speed, sin(direction) * speed)
	
	$Gibs.process_material.set_shader_parameter("velocity", velocity)
