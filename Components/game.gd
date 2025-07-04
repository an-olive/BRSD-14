@tool
extends Node2D
class_name Game

@export var paused: bool = false
@export var grid_size: Vector2i = Vector2i(21, 19)
@export var hole_radius: float = 9

@export var area: Rect2i = Rect2i(9, 9, 377, 341)

@export_category("Gibs")
@export var spawn_rate: float = 30
@export var debug_mouse_spawn_velocity_multiplier = 10

@export_category("Statistics")
## The time window duration in seconds, used for statistics keeping
@export var window_duration: float = 5
@export var force_constant: float = 1
@export var rotation_constant: float = 1

@export_category("Cost Lists")
@export var gib_costs: Array[int] = [20, 40, 80]
@export var rotation_milestones: Array[int] = []
@export var force_milestones: Array[int] = []
@export var expansion_milestones: Array[int] = []
signal costs_change
signal building_purchase


class GameStats:
	var gibs: int = 0
	var force: float = 0
	var rotation: float = 0
	var expansion: float = 0
	var max_force: float = 0
	var max_rotation: float = 0
	var max_expansion: float = 0
	var buildings: Array[InventoryBuilding] = []

var stats: GameStats = GameStats.new()
signal buildings_change

var tile_size: float
var hole_position: Vector2
var mouse_position: Vector2
var mouse_velocity: Vector2

var game_time: float = 0

class _RecentGib:
	var gib: Gibs.Gib
	var time: float

	func _init(gib: Variant) -> void:
		self.gib = gib
		time = Game.instance.game_time

	func velocity_towards_hole() -> float:
		var hole_pos = Game.instance.hole_position
		return (gib.vel.project(hole_pos - gib.pos)).length()

	func velocity_perpendicular_to_hole() -> float:
		var hole_pos = Game.instance.hole_position
		return (gib.vel.project((hole_pos - gib.pos).rotated(PI / 2))).length()

var recent_gibs_in_hole: Array[_RecentGib]

class _RecentInt:
	var value: int
	var time: float

	func _init(value: int) -> void:
		self.value = value
		time = Game.instance.game_time

var recent_gib_expansion: Array[_RecentInt]

static var instance: Game

static func int_to_string(value: Variant, fallback: String = "N/A") -> String:
	if value is int or value is float:
		return str(floori(value))
	return fallback

func _ready() -> void:
	#assert(instance == null, "Game must be a single instance")
	instance = self

	hole_position = Vector2(area.position) + Vector2(area.size) / 2

	assert(float(area.size.x + 1) / grid_size.x == float(area.size.y + 1) / grid_size.y, "Grid tiles must be squre")
	tile_size = float(area.size.x + 1) / grid_size.x

	$Grid.visible = Engine.is_editor_hint()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var prev_position = mouse_position
	mouse_position = get_viewport().get_mouse_position()
	mouse_velocity = mouse_position - prev_position

	if paused:
		return

	game_time += delta

	recent_gibs_in_hole = recent_gibs_in_hole.filter(func(rg): return rg.time + window_duration > game_time)
	stats.force = recent_gibs_in_hole.reduce(func(acc, rg): return acc + rg.velocity_towards_hole(), 0.0) * force_constant
	stats.rotation = recent_gibs_in_hole.reduce(func(acc, rg): return acc + rg.velocity_perpendicular_to_hole(), 0.0) * rotation_constant

	var occupied_tiles = Gibs.occupied_tiles()
	recent_gib_expansion.append(_RecentInt.new(len(occupied_tiles)))
	recent_gib_expansion = recent_gib_expansion.filter(func(rg): return rg.time + window_duration > game_time)
	if $DebugOverlay.visible:
		var image = Image.create(640, 360, false, Image.FORMAT_RGBA8)
		image.fill(Color.TRANSPARENT)
		for t in occupied_tiles:
			image.fill_rect(Rect2i(t * int(tile_size) - area.position, Vector2i(tile_size, tile_size)), Color(0, 1, 0, log(occupied_tiles[t])/10+.1))
		$DebugOverlay.texture = ImageTexture.create_from_image(image)
	stats.expansion = recent_gib_expansion.reduce(func(acc, v): return acc + v.value, 0) / len(recent_gib_expansion)
	
	stats.max_force = maxf(stats.max_force, stats.force)
	stats.max_rotation = maxf(stats.max_rotation, stats.rotation)
	stats.max_expansion = maxf(stats.max_expansion, stats.expansion)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT and area.has_point(mouse_position) and Input.is_action_pressed("debug_overlay"):
			Gibs.spawn_gib(mouse_position, mouse_velocity)

	if event.is_action_pressed("debug_overlay"):
		$DebugOverlay.visible = !$DebugOverlay.visible


func place_building(building: InventoryBuilding) -> void:
	if not stats.buildings.has(building):
		return
	stats.buildings.erase(building)
	building.building.location = building.location
	$Buildings.add_child(building.building)
	buildings_change.emit()
	
func purchase_with_gibs() -> void:
	if stats.gibs < gib_costs.front():
		return
	stats.gibs -= gib_costs.pop_front()
	costs_change.emit()
	building_purchase.emit()

func purchase_with_rotation() -> void:
	if stats.max_rotation < rotation_milestones.front():
		return
	rotation_milestones.pop_front()
	costs_change.emit()
	building_purchase.emit()
	
func purchase_with_force() -> void:
	if stats.max_force < force_milestones.front():
		return
	force_milestones.pop_front()
	costs_change.emit()
	building_purchase.emit()
	
func purchase_with_expansion() -> void:
	if stats.max_expansion < expansion_milestones.front():
		return
	expansion_milestones.pop_front()
	costs_change.emit()
	building_purchase.emit()


func _on_gibs_into_the_hole(_gib: Variant) -> void:
	stats.gibs += 1
	recent_gibs_in_hole.append(_RecentGib.new(_gib))

func _on_producer_gib_collided(_gib: Variant) -> void:
	pass
