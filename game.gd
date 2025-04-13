extends Node2D

@export var grid_size: Vector2i = Vector2i(21, 21)
@export var initial_hole_size: float = 1

@export_group("Visuals")
@export var background_color: Color = Color("FFF")
@export var grid_color: Color = Color("EEE")
@export var grid_line_width: float = 5

var tile_size: float
	
func _ready() -> void:
	var size = get_viewport_rect().size
	tile_size = min(size.x / grid_size.x, size.y / grid_size.y)

func _draw() -> void:
	draw_rect(Rect2(0, 0, tile_size * grid_size.x, tile_size * grid_size.y), background_color)
	for x in range(1, grid_size.x):
		draw_line(Vector2(tile_size * x, 0), Vector2(tile_size * x, tile_size * grid_size.y), grid_color, grid_line_width)
	for y in range(1, grid_size.y):
		draw_line(Vector2(0, tile_size * y), Vector2(tile_size * grid_size.x, tile_size * y), grid_color, grid_line_width)
	
