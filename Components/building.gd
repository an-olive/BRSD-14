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
		_update_transform()

@export_group("Physics", "")
@export 
var collisions_enabled = true:
	set(enabled):
		collisions_enabled = enabled
		update_configuration_warnings()

@export_range(0, 1, 0.05)
var elasticity: float = 1

signal gib_collided(gib)
signal gib_overlapping(gib)

func _ready() -> void:
	centered = false
	update_configuration_warnings()
	_update_transform()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []

	if not collision_shape and collisions_enabled:
		warnings.append("Please set `collision_shape` to a non-empty value.")

	return warnings

func _update_transform() -> void:
	if Game.instance == null:
		return
	
	transform.origin = Vector2(Game.instance.area.position) + Game.instance.tile_size * location

var _shape: Polygon2D = null
func get_shape() -> Polygon2D:
	if not collisions_enabled:
		if not collision_shape:
			return null
		
	if _shape == null:
		var node = get_node(collision_shape)
		if node is Polygon2D:
			_shape = node
			
	return _shape
	
static func has_collision(pos: Vector2i) -> bool:
	var building = []
	var building_node = Game.instance.find_child("Buildings", false)
	if building_node != null:
		for node in building_node.get_children():
			if node is Building and node.location == pos and node.get_shape():
				return true
	return false
