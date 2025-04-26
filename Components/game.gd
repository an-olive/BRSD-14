@tool
extends Node2D
class_name Game

@export var grid_size: Vector2i = Vector2i(21, 19)
@export var hole_radius: float = 9

@export_category("Area")
@export var area_origin: Vector2i = Vector2i(9, 9)
@export var area_size: Vector2i = Vector2i(377, 341)

@export_category("Gibs")
@export var spawn_rate: float = 30
@export var debug_mouse_spawn_velocity_multiplier = 10

var tile_size: float
var hole_position: Vector2
var mouse_position: Vector2
var mouse_velocity: Vector2

var gibs_in_hole: int

static var instance: Game

func _ready() -> void:
	#assert(instance == null, "Game must be a single instance")
	instance = self
	
	hole_position = Vector2(area_origin) + Vector2(area_size) / 2
	
	assert((area_size.x + 1) / grid_size.x == (area_size.y + 1) / grid_size.y, "Grid tiles must be squre")
	tile_size = (area_size.x + 1) / grid_size.x
	
	$Grid.visible = Engine.is_editor_hint()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	var prev_position = mouse_position
	mouse_position = get_viewport().get_mouse_position()
	mouse_velocity = mouse_position - prev_position
	
	$Label.text = "Gibs that have succumbed\nto the hole: %d\n\nGibs in total: %d" % [gibs_in_hole, len(Gibs.gibs)]

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
		
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			Gibs.spawn_gib(mouse_position, mouse_velocity)


func _on_gibs_into_the_hole(_gib: Variant) -> void:
	gibs_in_hole += 1
