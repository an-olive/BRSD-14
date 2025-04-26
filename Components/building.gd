@tool
@icon("res://Components/Building.svg")
class_name Building extends Sprite2D

@export_node_path("Polygon2D")
var collision_shape: NodePath:
	set(shape):
		collision_shape = shape
		update_configuration_warnings()
		
@export
var location: Vector2i = Vector2i(0, 0):
	set(loc):
		location = loc
		update_transform()

@export_group("Physics", "")
@export 
var collisions_enabled = true:
	set(enabled):
		collisions_enabled = enabled
		update_configuration_warnings()

@export_range(0, 1, 0.05)
var elasticity: float = 1

func _ready() -> void:
	centered = false
	update_configuration_warnings()
	update_transform()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []

	if not collision_shape and collisions_enabled:
		warnings.append("Please set `collision_shape` to a non-empty value.")

	return warnings

func update_transform() -> void:
	if Game.instance == null:
		return
	
	print(Game.instance.tile_size)
	transform.origin = Vector2(Game.instance.area_origin) + Game.instance.tile_size * location
