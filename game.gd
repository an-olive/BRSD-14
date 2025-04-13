extends Node2D

@export var grid_size: Vector2i = Vector2i(21, 21)
@export var initial_hole_size: float = 1

var tile_size: float
	
func _ready() -> void:
	var size = get_viewport_rect().size
	tile_size = min(size.x / grid_size.x, size.y / grid_size.y)
