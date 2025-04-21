extends Node2D

@export var grid_size: Vector2i = Vector2i(21, 19)
@export var initial_hole_size: float = 1

@export_category("Gibs")
@export var spawn_rate: float = 30
@export var debug_mouse_spawn_velocity_multiplier = 10

var tile_size: float
var mouse_position: Vector2
var mouse_velocity: Vector2
	
func _ready() -> void:
	var size = get_viewport_rect().size
	tile_size = min(size.x / grid_size.x, size.y / grid_size.y)
	
func _process(_delta: float) -> void:
	var prev_position = mouse_position
	mouse_position = get_viewport().get_mouse_position()
	mouse_velocity = mouse_position - prev_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			$Gibs.spawn_gib(mouse_position, mouse_velocity)
