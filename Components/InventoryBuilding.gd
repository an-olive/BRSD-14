@tool
@icon("res://Components/InventoryBuilding.svg")
class_name InventoryBuilding extends TextureRect

@export var invalid_tint: Color = Color(1.0, 0.0, 0.0, 1.0)

@export_category("Placement shader")
@export var lighten: float = 0.25;
@export var invalid_red: float = 2.0;
@export var opacity: float = 0.75;

var building: Building

signal on_selected
signal on_place

var selected = false:
	set(state):
		selected = state
		$Outline.visible = selected
		$Ghost.visible = selected
		$Grid.visible = selected
		if selected:
			on_selected.emit(self)
		if valid and not selected:
			on_place.emit(self)

var dragging = false

var valid = false:
	set(state):
		valid = state
		$Ghost.material.set_shader_parameter("is_valid", valid)

var location: Vector2i

func with(building: Building) -> InventoryBuilding:
	self.building = building
	texture = building.texture
	$Ghost.texture = building.texture
	return self

func _ready() -> void:
	$Ghost.material.set_shader_parameter("lighten", lighten)
	$Ghost.material.set_shader_parameter("invalid_red", invalid_red)
	$Ghost.material.set_shader_parameter("opacity", opacity)


func update_ghost_position(position: Vector2) -> void:
	if Game.instance.area.has_point(position):
		var tileIndex = (position - Vector2(Game.instance.area.position)) / Game.instance.tile_size
		$Ghost.position = Vector2(Game.instance.area.position) + Game.instance.tile_size * Vector2i(tileIndex)
		valid = building.is_valid_position(tileIndex)
		location = tileIndex
		return

	$Ghost.position = position - $Ghost.size / 2
	valid = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if event.pressed or dragging:
				update_ghost_position(event.global_position)
				selected = !selected
				dragging = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and dragging and event.button_index == MOUSE_BUTTON_LEFT:
		selected = false
		dragging = false
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			dragging = true
		if selected:
			update_ghost_position(event.global_position)
